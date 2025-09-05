# Uber & Lyft SQL Data Analysis Project

##  Project Overview

This project is a **complete end-to-end SQL analysis on an Uber & Lyft rides dataset**. The dataset contains ride details such as cab type, price, distance, surge multiplier, and timestamps.

The goal was to simulate a **real-world data analyst workflow** — from setting up staging tables, cleaning raw text data, parsing into correct types, running exploratory queries, and finally answering **business-style questions** about pricing, surge, and ride behavior.

Instead of just writing random queries, this project was structured like a **moderate-level SQL portfolio project** that demonstrates practical data analysis skills.

---

##  Dataset

**Source:** Uber & Lyft Rides Dataset (multiple thousands of rows).

* **Full Dataset:** `data/rides.csv`

  * Complete dataset used for all queries.
  * Too large to preview on GitHub; click **"View raw"** to download.

* **Sample Dataset:** `data/rides_sample.csv`

  * Smaller file (\~1–2k rows).
  * Added for quick preview directly on GitHub.

### Fields Included:

* `distance` → Distance between source & destination (miles)
* `cab_type` → Uber or Lyft
* `time_stamp` → Epoch time when ride info was captured
* `destination` → Destination of the ride
* `source` → Starting point of the ride
* `price` → Price estimate in USD
* `surge_multiplier` → Price surge factor (default = 1)
* `id` → Unique ride identifier
* `product_id` → Internal Uber/Lyft product type identifier
* `name` → Visible ride type (e.g., UberPool, UberXL, Lyft Lux)


---

##   Steps Followed

### 1. **Data Setup**

* Created schema `rides`.
* Created **raw staging table** with all fields as `TEXT` to avoid parsing errors.
* Loaded CSV data into staging table.
* Built a **cleaned table** with proper datatypes (NUMERIC, TIMESTAMP, etc).

### 2. **Data Cleaning & Parsing**

* Converted epoch `time_stamp` → PostgreSQL `TIMESTAMP`.
* Removed rows with missing/NULL `price` or `distance`.
* Deduplicated rides using `id`.
* Ensured surge multipliers default to 1 if missing.

### 3. **Exploration Queries**

* Counted total rides by cab type.
* Found unique ride types (UberXL, Lyft Lux, UberPool, etc).
* Checked price distribution across ride types.
* Verified if surge multipliers >1 were frequent or rare.

### 4. **Business Questions Answered**

Some of the SQL-driven insights include:

* Which cab type (Uber vs Lyft) had more rides?
* Average price per ride type (e.g., UberXL vs Lyft Lux).
* Surge multiplier effect → how much do prices jump under surge?
* Top 5 most expensive ride types.
* Average ride distance by cab type.
* Hourly/Day-of-week patterns in rides (using timestamp).
* Correlation between distance and price.

### 5. **Transformations & Deeper Analysis**

* Added `price_per_mile` = `price / distance`.
* Segmented rides into **Low / Medium / High price tiers** using `CASE`.
* Calculated **market share of each ride type** within Uber and Lyft.
* Looked at **time-based surge trends** (e.g., peak hours).

---

##  Key Insights

* **Uber vs Lyft:** One platform consistently dominated in number of rides.
* **Pricing:** Premium options (e.g., UberBlack, Lyft Lux) were **4–6x costlier** than base rides.
* **Surge:** Surge multipliers significantly affected price, especially at night/weekend.
* **Distance vs Price:** Positive correlation, but not perfectly linear (short rides often overpriced due to base fares).
* **Market Share:** A small number of ride types made up the majority of bookings.

---

##  SQL Functions & Concepts Used

This project demonstrates **moderate SQL skills** beyond basic SELECT queries:

### Aggregations

* `COUNT()` – ride counts per cab type, per product
* `AVG()` – average price, distance
* `SUM()` – total revenue estimates
* `ROUND()` – clean formatting

### Conditional Logic

* `CASE WHEN` – classifying rides into Low/Medium/High price tiers

### Data Cleaning

* Handling `NULL` values in price/distance
* Parsing epoch time → `TO_TIMESTAMP()`
* Removing duplicates via `ROW_NUMBER()`

### Grouping & Filtering

* `GROUP BY` – cab type, ride type, hour of day
* `HAVING` – filtering aggregated groups

### Sorting & Limiting

* `ORDER BY … LIMIT` – top-N expensive rides

### Window Functions (Intermediate SQL)

* `ROW_NUMBER() OVER (PARTITION BY … ORDER BY …)` → e.g., top 5 most expensive rides per cab type
* `SUM() OVER (PARTITION BY …)` → ride type market share

### Date & Time Functions

* `EXTRACT(HOUR FROM timestamp)` – hourly patterns
* `EXTRACT(DOW FROM timestamp)` – day-of-week trends

### Statistical Function

* `CORR(distance, price)` → correlation check
Do you want me to also **add a “Business Case Story” section** (like framing it as if Uber’s pricing team hired you to investigate surge & competition with Lyft)? That would make it even stronger for recruiters.
