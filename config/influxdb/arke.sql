CREATE DATABASE arke_development;

CREATE CONTINUOUS QUERY "trade_to_cq_1m" ON arke_development
RESAMPLE EVERY 5s FOR 10m
BEGIN
  SELECT FIRST(price) AS open, max(price) AS high, min(price) AS low, last(price) AS close, sum(amount) AS volume INTO candles_1m FROM trades GROUP BY time(1m), market fill(null)
END;

CREATE CONTINUOUS QUERY "trade_amount_to_cq_1m" ON arke_development
RESAMPLE EVERY 5s FOR 10m
BEGIN
  SELECT sum(amount) AS volume INTO candles_1m FROM trades GROUP BY time(1m), market fill(0)
END;

CREATE CONTINUOUS QUERY "cq_5m" ON arke_development
RESAMPLE EVERY 5s FOR 10m
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_5m" FROM "candles_1m" GROUP BY time(5m), market
END;

CREATE CONTINUOUS QUERY "cq_15m" ON arke_development
RESAMPLE EVERY 5s FOR 30m
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_15m" FROM "candles_5m" GROUP BY time(15m), market
END;

CREATE CONTINUOUS QUERY "cq_30m" ON arke_development
RESAMPLE EVERY 5s FOR 1h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_30m" FROM "candles_15m" GROUP BY time(30m), market
END;

CREATE CONTINUOUS QUERY "cq_1h" ON arke_development
RESAMPLE EVERY 5s FOR 2h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_1h" FROM "candles_30m" GROUP BY time(1h), market
END;

CREATE CONTINUOUS QUERY "cq_2h" ON arke_development
RESAMPLE EVERY 5s FOR 4h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_2h" FROM "candles_1h" GROUP BY time(2h), market
END;

CREATE CONTINUOUS QUERY "cq_4h" ON arke_development
RESAMPLE EVERY 5s FOR 8h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_4h" FROM "candles_2h" GROUP BY time(4h), market
END;

CREATE CONTINUOUS QUERY "cq_6h" ON arke_development
RESAMPLE EVERY 5s FOR 12h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_6h" FROM "candles_2h" GROUP BY time(6h), market
END;

CREATE CONTINUOUS QUERY "cq_12h" ON arke_development
RESAMPLE EVERY 5s FOR 24h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_12h" FROM "candles_6h" GROUP BY time(12h), market
END;

CREATE CONTINUOUS QUERY "cq_1d" ON arke_development
RESAMPLE EVERY 5s FOR 2d
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_1d" FROM "candles_6h" GROUP BY time(1d), market
END;

CREATE CONTINUOUS QUERY "cq_3d" ON arke_development
RESAMPLE EVERY 5s FOR 6d
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_3d" FROM "candles_1d" GROUP BY time(3d), market
END;

CREATE CONTINUOUS QUERY "cq_1w" ON arke_development
RESAMPLE EVERY 5s FOR 2w
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_1w" FROM "candles_1d" GROUP BY time(7d), market
END;
