/**
 * Quick local smoke test for AffiliateFetcher.
 * Usage: npm run test:fetcher
 *
 * Requires functions/.env with AWIN_API_TOKEN and AWIN_PUBLISHER_ID set.
 */

import {AffiliateFetcher} from "../lib/affiliateFetcher.js";

try {
  const fetcher = new AffiliateFetcher();

  console.log("Fetching deals from Awin...\n");
  const start = Date.now();
  const deals = await fetcher.fetchDeals();
  const elapsed = Date.now() - start;

  console.log(JSON.stringify(deals, null, 2));
  console.log(`\n── ${deals.length} deal(s) in ${elapsed}ms ──`);
} catch (err) {
  console.error("Error:", err.message);
  process.exit(1);
}
