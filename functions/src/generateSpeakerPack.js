const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { createCanvas, loadImage, registerFont } = require('canvas');
const QRCode = require('qrcode');
const archiver = require('archiver');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const firestore = admin.firestore();
const storage = admin.storage();

/**
 * Cloud Function to generate speaker pack for an event
 * @param {string} eventId - The ID of the event
 * @returns {Promise<{downloadUrl: string}>} - The download URL for the generated speaker pack
 */
exports.generateSpeakerPack = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated and admin
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated to generate speaker pack'
      );
    }

    // Get the event ID from the request
    const { eventId } = data;
    if (!eventId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Event ID is required'
      );
    }

    // Get event details
    const eventDoc = await firestore.collection('events').doc(eventId).get();
    if (!eventDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Event not found'
      );
    }

    const eventData = eventDoc.data();
    const eventTitle = eventData.title;
    const eventDate = new Date(eventData.startDate.toDate()).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
    const eventVenue = eventData.venue;

    // Get accepted talks for this event
    const talksSnapshot = await firestore
      .collection('talks')
      .where('eventId', '==', eventId)
      .where('status', '==', 'accepted')
      .get();

    if (talksSnapshot.empty) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'No accepted talks found for this event'
      );
    }

    // Create a temporary directory for the images
    const tempDir = os.tmpdir();
    const imagesDir = path.join(tempDir, 'speaker_images');
    fs.mkdirSync(imagesDir, { recursive: true });

    // Register fonts
    registerFont(path.join(__dirname, 'assets/fonts/Roboto-Bold.ttf'), { family: 'Roboto', weight: 'bold' });
    registerFont(path.join(__dirname, 'assets/fonts/Roboto-Regular.ttf'), { family: 'Roboto', weight: 'normal' });

    // Generate images for each talk
    const imagePromises = [];
    const talks = [];

    talksSnapshot.forEach(talkDoc => {
      const talkData = talkDoc.data();
      talks.push({ id: talkDoc.id, ...talkData });
      imagePromises.push(generateSpeakerImage(talkDoc.id, talkData, eventTitle, eventDate, eventVenue, imagesDir));
    });

    // Wait for all images to be generated
    await Promise.all(imagePromises);

    // Create a zip file with all the images
    const zipFilePath = path.join(tempDir, `speaker_pack_${eventId}.zip`);
    await createZipFile(imagesDir, zipFilePath);

    // Upload the zip file to Firebase Storage
    const bucket = storage.bucket();
    const zipFileName = `speaker_packs/${eventId}/speaker_pack_${Date.now()}.zip`;
    await bucket.upload(zipFilePath, {
      destination: zipFileName,
      metadata: {
        contentType: 'application/zip',
        metadata: {
          firebaseStorageDownloadTokens: eventId,
        }
      }
    });

    // Generate a download URL
    const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(zipFileName)}?alt=media&token=${eventId}`;

    // Clean up temporary files
    fs.unlinkSync(zipFilePath);
    fs.rmSync(imagesDir, { recursive: true, force: true });

    return { downloadUrl };
  } catch (error) {
    console.error('Error generating speaker pack:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Error generating speaker pack: ${error.message}`
    );
  }
});

/**
 * Generate a speaker image for a talk
 * @param {string} talkId - The ID of the talk
 * @param {Object} talkData - The talk data
 * @param {string} eventTitle - The title of the event
 * @param {string} eventDate - The formatted date of the event
 * @param {string} eventVenue - The venue of the event
 * @param {string} outputDir - The directory to save the image
 * @returns {Promise<void>}
 */
async function generateSpeakerImage(talkId, talkData, eventTitle, eventDate, eventVenue, outputDir) {
  try {
    // Get speaker details
    const speakerId = talkData.speakerId;
    const speakerDoc = await firestore.collection('speakers').doc(speakerId).get();
    
    if (!speakerDoc.exists) {
      throw new Error(`Speaker not found for talk ${talkId}`);
    }
    
    const speakerData = speakerDoc.data();
    const speakerName = speakerData.name;
    const speakerTitle = speakerData.title || '';
    const talkTitle = talkData.title;
    
    // Create a canvas for the image (1080x1080 pixels)
    const canvas = createCanvas(1080, 1080);
    const ctx = canvas.getContext('2d');
    
    // Draw background
    ctx.fillStyle = '#f5f5f5';
    ctx.fillRect(0, 0, 1080, 1080);
    
    // Draw colored header bar
    ctx.fillStyle = '#3f51b5'; // Primary color
    ctx.fillRect(0, 0, 1080, 200);
    
    // Draw event title
    ctx.font = 'bold 40px Roboto';
    ctx.fillStyle = '#ffffff';
    ctx.textAlign = 'center';
    ctx.fillText(eventTitle, 540, 80);
    
    // Draw event date and venue
    ctx.font = '30px Roboto';
    ctx.fillText(`${eventDate} | ${eventVenue}`, 540, 130);
    
    // Draw speaker name
    ctx.font = 'bold 60px Roboto';
    ctx.fillStyle = '#212121';
    ctx.textAlign = 'center';
    ctx.fillText(speakerName, 540, 300);
    
    // Draw speaker title
    if (speakerTitle) {
      ctx.font = '30px Roboto';
      ctx.fillStyle = '#757575';
      ctx.fillText(speakerTitle, 540, 350);
    }
    
    // Draw talk title
    ctx.font = 'bold 40px Roboto';
    ctx.fillStyle = '#3f51b5';
    
    // Handle long talk titles by wrapping text
    const maxWidth = 900;
    const words = talkTitle.split(' ');
    let line = '';
    let y = 450;
    
    for (let i = 0; i < words.length; i++) {
      const testLine = line + words[i] + ' ';
      const metrics = ctx.measureText(testLine);
      const testWidth = metrics.width;
      
      if (testWidth > maxWidth && i > 0) {
        ctx.fillText(line, 540, y);
        line = words[i] + ' ';
        y += 50;
      } else {
        line = testLine;
      }
    }
    ctx.fillText(line, 540, y);
    
    // Generate QR code for the talk
    const qrCodeUrl = `https://flutter-birmingham-hub.web.app/talks/${talkId}`;
    const qrCodeDataUrl = await QRCode.toDataURL(qrCodeUrl, {
      errorCorrectionLevel: 'H',
      margin: 1,
      width: 200,
      color: {
        dark: '#000000',
        light: '#ffffff'
      }
    });
    
    // Load and draw QR code
    const qrCodeImage = await loadImage(qrCodeDataUrl);
    ctx.drawImage(qrCodeImage, 440, 700, 200, 200);
    
    // Draw QR code caption
    ctx.font = '24px Roboto';
    ctx.fillStyle = '#757575';
    ctx.fillText('Scan to view talk details', 540, 940);
    
    // Draw footer
    ctx.font = 'bold 24px Roboto';
    ctx.fillStyle = '#3f51b5';
    ctx.fillText('Flutter Birmingham Hub', 540, 1000);
    
    // Save the image
    const outputPath = path.join(outputDir, `${speakerName.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_${talkId}.png`);
    const buffer = canvas.toBuffer('image/png');
    fs.writeFileSync(outputPath, buffer);
    
    return outputPath;
  } catch (error) {
    console.error(`Error generating image for talk ${talkId}:`, error);
    throw error;
  }
}

/**
 * Create a zip file with all the images
 * @param {string} sourceDir - The directory containing the images
 * @param {string} outputPath - The path to save the zip file
 * @returns {Promise<void>}
 */
function createZipFile(sourceDir, outputPath) {
  return new Promise((resolve, reject) => {
    const output = fs.createWriteStream(outputPath);
    const archive = archiver('zip', {
      zlib: { level: 9 } // Maximum compression
    });
    
    output.on('close', () => {
      console.log(`Zip file created: ${archive.pointer()} total bytes`);
      resolve();
    });
    
    archive.on('error', (err) => {
      reject(err);
    });
    
    archive.pipe(output);
    archive.directory(sourceDir, false);
    archive.finalize();
  });
}
