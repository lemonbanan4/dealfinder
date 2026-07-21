-- Performance-critical indexes for the PrisPuls Postgres (Supabase) database.
--
-- This project has no migration framework — the DB was created ad hoc and
-- its schema lives only in the live instance. This file records the indexes
-- the API/scraper depend on for acceptable performance, as idempotent
-- statements, so they're in version control and reproducible on a rebuild
-- rather than being invisible production-only artifacts. Safe to re-run.
--
-- Apply with: psql "$DATABASE_URL" -f db/indexes.sql
-- (CONCURRENTLY avoids locking the table against writes; it cannot run
-- inside a transaction block, so run this file with autocommit / psql's
-- default single-statement mode, not wrapped in BEGIN/COMMIT.)

-- ── price_history ───────────────────────────────────────────────────────────
-- Both /api/deals/biggest-drops and /api/stats run a correlated LATERAL
-- subquery per product: "the most recent price for this product from >=24h
-- ago" (WHERE product_id = ? AND recorded_at <= ? ORDER BY recorded_at DESC
-- LIMIT 1). With only the separate single-column indexes that existed before
-- (product_id alone, recorded_at alone), Postgres fetched every history row
-- for the product and then top-N-sorted them by recorded_at — for all ~24k
-- products, on every homepage load. Measured: 4817 ms for biggest-drops.
-- This composite index turns each per-product lookup into an instant index
-- scan (no sort). Measured after: 209 ms — a ~23x speedup.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_price_history_product_recorded
    ON price_history (product_id, recorded_at DESC);

-- Pre-existing indexes (documented for completeness, already present):
--   price_history_pkey                     UNIQUE (id)
--   price_history_product_price_day_key    UNIQUE (product_id, price, price_history_utc_date(recorded_at))
--   idx_price_history_product              (product_id)
--   idx_price_history_date                 (recorded_at)
-- The two single-column indexes above are now largely redundant with the
-- composite one for the query patterns in this codebase, but are left in
-- place (dropping them is a separate, optional cleanup).
