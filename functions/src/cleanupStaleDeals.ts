import {getFirestore} from "firebase-admin/firestore";
import {logger} from "firebase-functions";

const STALE_THRESHOLD_DAYS = 7;
const BATCH_SIZE = 400; // Firestore batch limit is 500; stay well under it

/**
 * Deletes deals from the `deals` collection whose `scrapedAt` timestamp
 * is older than STALE_THRESHOLD_DAYS. Processes in batches to stay within
 * Firestore write limits.
 *
 * @return {Promise<number>} The number of documents deleted.
 */
export async function cleanupStaleDeals(): Promise<number> {
  const db = getFirestore();
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - STALE_THRESHOLD_DAYS);

  const staleQuery = db
    .collection("deals")
    .where("scrapedAt", "<", cutoff)
    .limit(BATCH_SIZE);

  let totalDeleted = 0;

  // Loop in case more than BATCH_SIZE stale documents exist.
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const snapshot = await staleQuery.get();
    if (snapshot.empty) break;

    const batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    totalDeleted += snapshot.size;
    logger.info(`cleanupStaleDeals: deleted batch of ${snapshot.size}`);

    if (snapshot.size < BATCH_SIZE) break;
  }

  logger.info(`cleanupStaleDeals: total removed = ${totalDeleted}`);
  return totalDeleted;
}
