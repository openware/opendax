CREATE DATABASE arke_production;

CREATE CONTINUOUS QUERY "trade_to_cq_1m" ON arke_production
RESAMPLE EVERY 10s FOR 10m
BEGIN
  SELECT FIRST(price) AS open, max(price) AS high, min(price) AS low, last(price) AS close, sum(amount) AS volume INTO candles_1m FROM trades GROUP BY time(1m), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_5m" ON arke_production
RESAMPLE EVERY 10s FOR 10m
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_5m" FROM "candles_1m" GROUP BY time(5m), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_15m" ON arke_production
RESAMPLE EVERY 10s FOR 15m
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_15m" FROM "candles_5m" GROUP BY time(15m), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_30m" ON arke_production
RESAMPLE EVERY 10s FOR 5h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_30m" FROM "candles_15m" GROUP BY time(30m), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_1h" ON arke_production
RESAMPLE EVERY 10s FOR 10h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_1h" FROM "candles_30m" GROUP BY time(1h), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_2h" ON arke_production
RESAMPLE EVERY 10s FOR 10h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_2h" FROM "candles_1h" GROUP BY time(2h), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_4h" ON arke_production
RESAMPLE EVERY 10s FOR 40h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_4h" FROM "candles_2h" GROUP BY time(4h), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_6h" ON arke_production
RESAMPLE EVERY 10s FOR 40h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_6h" FROM "candles_2h" GROUP BY time(6h), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_12h" ON arke_production
RESAMPLE EVERY 10s FOR 40h
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_12h" FROM "candles_6h" GROUP BY time(12h), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_1d" ON arke_production
RESAMPLE EVERY 10s FOR 10d
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_1d" FROM "candles_6h" GROUP BY time(1d), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_3d" ON arke_production
RESAMPLE EVERY 10s FOR 10d
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_3d" FROM "candles_1d" GROUP BY time(3d), market, exchange
END;

CREATE CONTINUOUS QUERY "cq_1w" ON arke_production
RESAMPLE EVERY 10s FOR 21d
BEGIN
  SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO "candles_1w" FROM "candles_1d" GROUP BY time(7d), market, exchange
END;