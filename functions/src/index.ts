import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {setGlobalOptions} from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import {AffiliateFetcher} from "./affiliateFetcher.js";
import {cleanupStaleDeals} from "./cleanupStaleDeals.js";

initializeApp();

setGlobalOptions({maxInstances: 2, region: "europe-west1"});

// ── Deal Aggregator Engine ────────────────────────────────────────────────
// Runs every 6 hours. Batch-upserts deals with merge:true so price updates
// never overwrite unrelated fields. Stale deals (>7 days) are pruned after.

export const aggregateDeals = onSchedule(
  {
    schedule: "every 6 hours",
    timeoutSeconds: 300,
  },
  async () => {
    logger.info("aggregateDeals: starting run");

    const fetcher = new AffiliateFetcher();
    const deals = await fetcher.fetchDeals();
    logger.info(`aggregateDeals: fetched ${deals.length} deals`);

    const db = getFirestore();
    const now = FieldValue.serverTimestamp();

    // Firestore allows max 500 ops per batch; each set() is 1 op.
    const BATCH_SIZE = 400;
    let written = 0;

    for (let i = 0; i < deals.length; i += BATCH_SIZE) {
      const chunk = deals.slice(i, i + BATCH_SIZE);
      const batch = db.batch();

      for (const deal of chunk) {
        const ref = db.collection("deals").doc(deal.id);
        batch.set(
          ref,
          {
            id: deal.id,
            title: deal.title,
            priceEur: deal.priceEur,
            originalCurrency: deal.originalCurrency,
            originalPrice: deal.originalPrice,
            sourceName: deal.sourceName,
            url: deal.url,
            imageUrl: deal.imageUrl ?? null,
            scrapedAt: now,
          },
          {merge: true},
        );
      }

      await batch.commit();
      written += chunk.length;
      logger.info(`aggregateDeals: wrote batch of ${chunk.length}`);
    }

    logger.info(`aggregateDeals: upserted ${written} deals`);

    const deleted = await cleanupStaleDeals();
    logger.info(
      `aggregateDeals: run complete — +${written} upserted, -${deleted} pruned`,
    );
  },
);
