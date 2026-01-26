const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const firestore = admin.firestore();

/**
 * Cloud Function to get insights data for admin dashboard
 * @returns {Promise<Object>} - The insights data
 */
exports.getInsights = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated and admin
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to access insights"
      );
    }

    // Get all speakers
    const speakersSnapshot = await firestore.collection("speakers").get();
    const totalSpeakers = speakersSnapshot.size;

    // Get all talks
    const talksSnapshot = await firestore.collection("talks").get();
    const talks = [];
    talksSnapshot.forEach((doc) => {
      talks.push({ id: doc.id, ...doc.data() });
    });
    const totalTalks = talks.length;

    // Calculate acceptance rate
    const acceptedTalks = talks.filter((talk) => talk.status === "accepted");
    const acceptanceRate =
      totalTalks > 0 ? (acceptedTalks.length / totalTalks) * 100 : 0;

    // Get all feedback
    const feedbackSnapshot = await firestore.collection("feedback").get();
    const feedbackItems = [];
    feedbackSnapshot.forEach((doc) => {
      feedbackItems.push({ id: doc.id, ...doc.data() });
    });

    // Calculate average rating overall
    let totalRating = 0;
    feedbackItems.forEach((item) => {
      totalRating += item.rating;
    });
    const averageRating =
      feedbackItems.length > 0 ? totalRating / feedbackItems.length : 0;

    // Calculate average rating per talk
    const talkRatings = {};
    const talkRatingsData = [];

    feedbackItems.forEach((item) => {
      if (item.talkId) {
        if (!talkRatings[item.talkId]) {
          talkRatings[item.talkId] = {
            talkId: item.talkId,
            totalRating: 0,
            count: 0,
            average: 0,
            title: "",
          };
        }

        talkRatings[item.talkId].totalRating += item.rating;
        talkRatings[item.talkId].count += 1;
      }
    });

    // Get talk titles and calculate averages
    for (const talkId in talkRatings) {
      const talk = talks.find((t) => t.id === talkId);
      if (talk) {
        talkRatings[talkId].title = talk.title || "Unknown Talk";
        talkRatings[talkId].average =
          talkRatings[talkId].totalRating / talkRatings[talkId].count;
        talkRatingsData.push({
          talkId: talkId,
          title: talkRatings[talkId].title,
          average: talkRatings[talkId].average,
          count: talkRatings[talkId].count,
        });
      }
    }

    // Sort by average rating (highest first)
    talkRatingsData.sort((a, b) => b.average - a.average);

    // Get top 10 talks by rating
    const topRatedTalks = talkRatingsData.slice(0, 10);

    // Calculate top tags
    const tagCounts = {};
    talks.forEach((talk) => {
      if (talk.tags && Array.isArray(talk.tags)) {
        talk.tags.forEach((tag) => {
          if (!tagCounts[tag]) {
            tagCounts[tag] = 0;
          }
          tagCounts[tag] += 1;
        });
      }
    });

    // Convert to array and sort by count (highest first)
    const tagCountsArray = Object.keys(tagCounts).map((tag) => ({
      tag,
      count: tagCounts[tag],
    }));

    tagCountsArray.sort((a, b) => b.count - a.count);

    // Get top 10 tags
    const topTags = tagCountsArray.slice(0, 10);

    // Get talk submissions over time
    const submissionsByMonth = {};
    talks.forEach((talk) => {
      if (talk.submittedAt) {
        const date = talk.submittedAt.toDate
          ? talk.submittedAt.toDate()
          : new Date(talk.submittedAt);
        const monthYear = `${date.getFullYear()}-${(date.getMonth() + 1)
          .toString()
          .padStart(2, "0")}`;

        if (!submissionsByMonth[monthYear]) {
          submissionsByMonth[monthYear] = 0;
        }

        submissionsByMonth[monthYear] += 1;
      }
    });

    // Convert to array and sort by date
    const submissionTrend = Object.keys(submissionsByMonth).map((month) => ({
      month,
      count: submissionsByMonth[month],
    }));

    submissionTrend.sort((a, b) => a.month.localeCompare(b.month));

    // Return all insights data
    return {
      totalSpeakers,
      totalTalks,
      acceptanceRate,
      averageRating,
      topRatedTalks,
      topTags,
      submissionTrend,
    };
  } catch (error) {
    console.error("Error getting insights:", error);
    throw new functions.https.HttpsError(
      "internal",
      `Error getting insights: ${error.message}`
    );
  }
});
