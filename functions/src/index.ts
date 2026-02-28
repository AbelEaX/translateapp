import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

/**
 * Helper to determine badge tier based on points
 */
function getBadgeForPoints(points: number): string | null {
    if (points >= 150) return "Dialect Master";
    if (points >= 50) return "Rising Star";
    if (points >= 0) return "Novice Translator";
    return null;
}

/**
 * Trigger 1: onTranslationCreated
 * Awards +5 points to the author when they submit a new translation.
 */
export const onTranslationCreated = onDocumentCreated(
    "gotranslate_db/translations_collection/translations/{translationId}",
    async (event) => {
        const snap = event.data;
        if (!snap) return;

        const data = snap.data();
        if (!data) return;

        const userId = data.userId;
        if (!userId) return;

        try {
            const userRef = db.collection("users").doc(userId);
            const userDoc = await userRef.get();

            let currentPoints = 0;
            let currentBadge = "Novice Translator";

            if (userDoc.exists) {
                const userData = userDoc.data();
                currentPoints = userData?.points || 0;
                currentBadge = userData?.badge || "Novice Translator";
            }

            const newPoints = currentPoints + 5;
            const newBadge = getBadgeForPoints(newPoints) || currentBadge;

            const updateData: any = {
                points: newPoints,
            };

            let badgeUpgraded = false;
            if (newBadge !== currentBadge && newPoints > currentPoints) {
                updateData.badge = newBadge;
                badgeUpgraded = true;
            }

            await userRef.set(updateData, { merge: true });

            // Build out targeted push notification
            const userProfile = await userRef.get();
            const fcmToken = userProfile.data()?.fcmToken;

            if (fcmToken) {
                if (badgeUpgraded) {
                    await fcm.send({
                        token: fcmToken,
                        notification: {
                            title: "🏅 Badge Unlocked!",
                            body: `Congratulations! You've earned the ${newBadge} badge!`,
                        },
                        data: { type: "badge_unlocked" },
                    });
                } else {
                    // General points notification
                    await fcm.send({
                        token: fcmToken,
                        notification: {
                            title: "🎉 Points Earned!",
                            body: "You earned +5 points for your new translation submission.",
                        },
                        data: { type: "points_earned" },
                    });
                }
            }

            console.log(`Awarded 5 points to user ${userId}. New total: ${newPoints}. Badge: ${newBadge}`);
        } catch (error) {
            console.error("Error updating points in onTranslationCreated:", error);
        }
    }
);

/**
 * Trigger 2: onTranslationScoreChanged
 * Calculates net score change (+2 per upvote, -1 per downvote) and adjusts author points.
 */
export const onTranslationScoreChanged = onDocumentUpdated(
    "gotranslate_db/translations_collection/translations/{translationId}",
    async (event) => {
        const change = event.data;
        if (!change) return;

        const beforeData = change.before.data();
        const afterData = change.after.data();

        if (!beforeData || !afterData) return;
        const userId = afterData.userId;
        if (!userId) return;

        // Remove unused score variables:
        // const beforeScore = beforeData.score || 0;
        // const afterScore = afterData.score || 0;

        // Calculate the raw upvotes and downvotes to determine precise point changes
        const beforeUp = beforeData.upvotes || 0;
        const afterUp = afterData.upvotes || 0;

        const beforeDown = beforeData.downvotes || 0;
        const afterDown = afterData.downvotes || 0;

        let pointDelta = 0;

        // Someone added an upvote
        if (afterUp > beforeUp) pointDelta += 2;
        // Someone removed an upvote
        if (afterUp < beforeUp) pointDelta -= 2;

        // Someone added a downvote
        if (afterDown > beforeDown) pointDelta -= 1;
        // Someone removed a downvote
        if (afterDown < beforeDown) pointDelta += 1;

        if (pointDelta === 0) return; // No score change

        try {
            const userRef = db.collection("users").doc(userId);
            const userDoc = await userRef.get();

            let currentPoints = 0;
            let currentBadge = "Novice Translator";

            if (userDoc.exists) {
                const userData = userDoc.data();
                currentPoints = userData?.points || 0;
                currentBadge = userData?.badge || "Novice Translator";
            }

            // Ensure points don't go below 0
            const newPoints = Math.max(0, currentPoints + pointDelta);
            const newBadge = getBadgeForPoints(newPoints) || currentBadge;

            const updateData: any = {
                points: newPoints,
            };

            let badgeUpgraded = false;
            if (newBadge !== currentBadge && newPoints > currentPoints) {
                updateData.badge = newBadge;
                badgeUpgraded = true;
            }

            await userRef.set(updateData, { merge: true });

            // Notifications
            const userProfile = await userRef.get();
            const fcmToken = userProfile.data()?.fcmToken;

            if (fcmToken) {
                if (badgeUpgraded) {
                    await fcm.send({
                        token: fcmToken,
                        notification: {
                            title: "🏅 Badge Unlocked!",
                            body: `Congratulations! You've earned the ${newBadge} badge!`,
                        },
                        data: { type: "badge_unlocked" },
                    });
                } else if (pointDelta > 0) {
                    // Send notification for upvote
                    await fcm.send({
                        token: fcmToken,
                        notification: {
                            title: "🌟 Translation Upvoted!",
                            body: `Someone liked your translation. Earnt +${pointDelta} points.`,
                        },
                        data: { type: "translation_upvoted", translationId: event.params.translationId },
                    });
                }
            }

            console.log(`Updated points for user ${userId} by ${pointDelta}. New total: ${newPoints}.`);
        } catch (error) {
            console.error("Error updating points in onTranslationScoreChanged:", error);
        }
    });
