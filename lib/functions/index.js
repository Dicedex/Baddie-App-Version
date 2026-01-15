const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.scoreProfile = functions.firestore
  .document("profiles/{userId}")
  .onWrite(async (snap, context) => {
    const data = snap.after.data();
    if (!data) return;

    let score = 0;

    // Completeness
    if (data.bio?.length > 20) score += 20;
    if (data.imageUrl) score += 20;
    if (data.videoUrl) score += 20;

    // Interests
    score += Math.min((data.interests?.length || 0) * 5, 20);

    // Activity
    score += 20;

    await snap.after.ref.update({ aiScore: score });
  });

  exports.callNotification = functions.firestore
  .document('calls/{callId}')
  .onCreate(async (snap) => {
    const data = snap.data();

    const payload = {
      notification: {
        title: 'Incoming Call',
        body: `${data.callerName} is calling you`,
      },
      data: {
        callId: snap.id,
        video: data.video.toString(),
      }
    };

    const user = await admin.firestore()
      .collection('users')
      .doc(data.receiverId)
      .get();

    if (!user.exists) return;

    return admin.messaging().sendToDevice(
      user.data().fcmToken,
      payload
    );
  });
