const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { generateSpeakerPack } = require("./src/generateSpeakerPack");
const { getInsights } = require("./src/getInsights");

// Initialize Firebase Admin
admin.initializeApp();

// Export the Cloud Functions
exports.generateSpeakerPack = generateSpeakerPack;
exports.getInsights = getInsights;
