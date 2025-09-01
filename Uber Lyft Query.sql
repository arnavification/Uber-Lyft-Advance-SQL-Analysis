-- Uber_Lyft_analysis.sql
-- PostgreSQL-compatible queries for Uber & Lyft Dataset
-- Advanced SQL Project
-- IMPORTANT: Create & connect to database 'uber' (see README) before running.

---------------------------------------------------
-- 1. SCHEMA & TABLE CREATION
---------------------------------------------------

CREATE SCHEMA IF NOT EXISTS rides;
SET search_path = rides, public;

-- Raw staging table (all fields as text for initial load)
CREATE TABLE IF NOT EXISTS rides (
  distance_text         text,
  cab_type_text         text,
  time_stamp_text       text,
  destination_text      text,
  source_text           text,
  price_text            text,
  surge_multiplier_text text,
  id_text               text,
  product_id_text       text,
  name_text             text
);

---------------------------------------------------
-- 2. INITIAL CHECKS
---------------------------------------------------

-- Sample rows
SELECT * FROM rides LIMIT 10;

-- Row count
SELECT COUNT(*) AS total_rows FROM rides;

---------------------------------------------------
-- 3. DATA EXPLORATION
---------------------------------------------------

-- Unique cab types
SELECT DISTINCT cab_type_text FROM rides;

-- Unique car categories
SELECT DISTINCT name_text FROM rides;

-- Unique sources
SELECT DISTINCT source_text FROM rides;

-- Unique destinations
SELECT DISTINCT destination_text FROM rides;

---------------------------------------------------
-- 4. SUMMARY STATISTICS
---------------------------------------------------

-- Basic stats: price & distance
SELECT 
    ROUND(AVG(CAST(price_text AS NUMERIC)),2) AS avg_price,
    ROUND(MIN(CAST(price_text AS NUMERIC)),2) AS min_price,
    ROUND(MAX(CAST(price_text AS NUMERIC)),2) AS max_price,
    ROUND(AVG(CAST(distance_text AS NUMERIC)),2) AS avg_distance,
    ROUND(MAX(CAST(distance_text AS NUMERIC)),2) AS max_distance
FROM rides;

---------------------------------------------------
-- 5. COMPARATIVE ANALYSIS
---------------------------------------------------

-- Uber vs Lyft pricing
SELECT 
    cab_type_text, 
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price, 
    ROUND(MAX(CAST(price_text AS NUMERIC)), 2) AS max_price, 
    COUNT(*) AS rides
FROM rides
GROUP BY cab_type_text;

-- Most expensive car categories
SELECT 
    name_text, 
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price, 
    MAX(CAST(price_text AS NUMERIC)) AS max_price
FROM rides
GROUP BY name_text
ORDER BY avg_price DESC
LIMIT 10;

-- Most popular routes
SELECT 
    source_text AS source,
    destination_text AS destination,
    COUNT(*) AS total_rides
FROM rides
GROUP BY source_text, destination_text
ORDER BY total_rides DESC
LIMIT 10;

-- Surge pricing impact
SELECT 
    surge_multiplier_text,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price, 
    COUNT(*) AS rides
FROM rides
GROUP BY surge_multiplier_text
ORDER BY surge_multiplier_text;

---------------------------------------------------
-- 6. PRICE VS DISTANCE RELATIONSHIP
---------------------------------------------------

SELECT 
    CASE 
        WHEN CAST(distance_text AS NUMERIC) < 2 THEN '0-2 km'
        WHEN CAST(distance_text AS NUMERIC) BETWEEN 2 AND 5 THEN '2-5 km'
        WHEN CAST(distance_text AS NUMERIC) BETWEEN 5 AND 10 THEN '5-10 km'
        ELSE '10+ km'
    END AS distance_bucket,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price,
    COUNT(*) AS rides
FROM rides
GROUP BY distance_bucket
ORDER BY MIN(CAST(distance_text AS NUMERIC));

---------------------------------------------------
-- 7. TIME-BASED ANALYSIS
---------------------------------------------------

-- Sample: converting timestamp
SELECT 
    to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000) AS ride_time,
    EXTRACT(HOUR FROM to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000)) AS ride_hour,
    TO_CHAR(to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000), 'Day') AS ride_day
FROM rides
LIMIT 10;

-- Rides by hour of day
SELECT 
    EXTRACT(HOUR FROM to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000)) AS ride_hour,
    COUNT(*) AS total_rides,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price
FROM rides
GROUP BY ride_hour
ORDER BY ride_hour;

-- Rides by day of week
SELECT 
    TO_CHAR(
        to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000), 
        'Day'
    ) AS ride_day,
    COUNT(*) AS total_rides,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price
FROM rides
GROUP BY ride_day
ORDER BY total_rides DESC;

---------------------------------------------------
-- 8. ADVANCED INSIGHTS
---------------------------------------------------

-- Ranking routes by price
SELECT 
    source_text AS source,
    destination_text AS destination,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price,
    RANK() OVER (ORDER BY AVG(CAST(price_text AS NUMERIC)) DESC) AS price_rank
FROM rides
GROUP BY source_text, destination_text
ORDER BY price_rank;

-- Top 3 ride categories overall
SELECT *
FROM (
    SELECT 
        name_text, 
        ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price,
        RANK() OVER (
            ORDER BY AVG(CAST(price_text AS NUMERIC)) DESC
        ) AS rnk
    FROM rides
    GROUP BY name_text
) t
WHERE rnk <= 3;

-- Surge vs normal revenue share
SELECT 
    CASE WHEN CAST(surge_multiplier_text AS NUMERIC) > 1 
         THEN 'Surge' ELSE 'Normal' END AS surge_flag,
    COUNT(*) AS total_rides,
    ROUND(AVG(CAST(price_text AS NUMERIC)),2) AS avg_price,
    ROUND(SUM(CAST(price_text AS NUMERIC)),2) AS total_revenue
FROM rides
GROUP BY surge_flag;

-- Approximate correlation (price per km)
SELECT 
    ROUND(SUM(CAST(price_text AS NUMERIC)) / SUM(CAST(distance_text AS NUMERIC)), 2) AS avg_price_per_km
FROM rides
WHERE CAST(distance_text AS NUMERIC) > 0;

-- Revenue contribution by car category
SELECT 
    name_text, 
    ROUND(SUM(CAST(price_text AS NUMERIC)),2) AS total_revenue,
    ROUND(SUM(CAST(price_text AS NUMERIC)) * 100.0 / 
          (SELECT SUM(CAST(price_text AS NUMERIC)) FROM rides), 2) AS revenue_percent
FROM rides
GROUP BY name_text
ORDER BY total_revenue DESC;

-- Detect outliers in pricing
SELECT *
FROM rides
WHERE CAST(price_text AS NUMERIC) > (
          SELECT AVG(CAST(price_text AS NUMERIC)) 
                 + 3*STDDEV(CAST(price_text AS NUMERIC)) 
          FROM rides
      )
ORDER BY CAST(price_text AS NUMERIC) DESC
LIMIT 10;
