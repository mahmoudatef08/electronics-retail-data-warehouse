# electronics-retail-data-warehouse

A data warehouse built on **PostgreSQL** with the **Medallion architecture** (Bronze → Silver → Gold).
It turns six raw CSV files of an electronics retailer (customers, products, stores, sales and exchange rates) into a clean **star schema** that is ready for analytics and BI.

---

## Table of Contents

- [Architecture](#architecture)
- [Dataset](#dataset)
- [Layers](#layers)
- [Data Model](#data-model)
- [Data Flow](#data-flow)
- [Business Logic](#business-logic)
- [Data Quality](#data-quality)
- [Repository Structure](#repository-structure)
- [How to Run](#how-to-run)
- [Validation](#validation)
- [Design Notes and Limitations](#design-notes-and-limitations)
- [Tech Stack](#tech-stack)

---

## Architecture

![Data Architecture](docs/images/01_data_architecture.png)

| Layer | Purpose | Objects |
|---|---|---|
| **Bronze** | Raw data, stored as-is (all columns `TEXT`) | 5 tables |
| **Silver** | Cleaned, typed and standardized data | 5 tables |
| **Gold** | Business-ready star schema | 4 dimensions + 1 fact (views) |

## Dataset

Six CSV files (in `Datasets/`):

| File | Rows | Description |
|---|---|---|
| `Customers.csv` | 15,266 | Customers: name, gender, birthday, city, state, country, continent (encoding **LATIN1**) |
| `Products.csv` | 2,517 | Products: name, brand, color, unit cost / price (USD), subcategory, category |
| `Stores.csv` | 67 | Stores: country, state, square meters, open date. Store `0` = **Online** |
| `Sales.csv` | 62,884 | Order lines (26,326 orders): dates, keys, quantity, currency |
| `Exchange_Rates.csv` | 11,215 | Daily exchange rates vs USD for 5 currencies (USD, EUR, GBP, CAD, AUD) |
| `Data_Dictionary.csv` | 37 fields | Column descriptions (reference only, not loaded) |

Sales cover **2016-01-01 to 2021-02-20**.

## Layers

### Bronze: raw

- Every column is stored as `TEXT`, with no cleaning and no business rules.
- Loaded by the stored procedure `bronze.load_bronze()` (`TRUNCATE` + `COPY ... CSV HEADER`).
- `Customers.csv` is loaded with `ENCODING 'LATIN1'`.

### Silver: cleaned

| Table | Main cleaning steps |
|---|---|
| `silver.customers` | `TRIM`; `INITCAP` on `city` only when it is all caps; `TO_DATE` on `birthday`; empty `state_code` becomes `NULL` (the code `NA` of Napoli, Italy is kept) |
| `silver.products` | Remove `$` and thousands commas from prices and cast to `DECIMAL(10,2)`; remove the brand prefix, the color suffix and the model code from `product_name` |
| `silver.stores` | Cast types, `TO_DATE` on `open_date` |
| `silver.sales` | Cast keys and quantity to `INTEGER`, `TO_DATE` on both dates; empty `delivery_date` stays `NULL` |
| `silver.exchange_rates` | `TO_DATE` on the date, `DECIMAL(10,4)` on the rate |

Every Silver table has a `dwh_create_date` audit column.

### Gold: star schema

All Gold objects are **views** (one script per object in `scripts/gold/`):

| Object | Description |
|---|---|
| `gold.dim_customers` | Customers with a surrogate `customer_key` (original key kept as `customer_id`) |
| `gold.dim_products` | Products with a surrogate `product_key` (original key kept as `product_id`) |
| `gold.dim_stores` | Stores with a surrogate `store_key` and a `store_type` (`Online` / `Physical`) |
| `gold.dim_date` | Generated calendar, one row per day (full years 2016 to 2021) |
| `gold.fact_sales` | One row per order line (`order_number` + `line_item`) |

## Data Model

![Data Model](docs/images/03_data_model.png)

`fact_sales` is joined to `dim_date` twice (order date and delivery date). The delivery relationship is optional because most order lines have no delivery date.

## Data Flow

Data integration, source to Gold:

![Data Integration](docs/images/02_data_integration.png)

Silver to Gold in detail:

![Data Flow Silver to Gold](docs/images/04_data_flow_silver_to_gold.png)

## Business Logic

`fact_sales` measures:

| Column | Formula |
|---|---|
| `sales_amount_usd` | `quantity × unit_price_usd` |
| `cost_amount_usd` | `quantity × unit_cost_usd` |
| `profit_usd` | `sales_amount_usd − cost_amount_usd` |
| `exchange_rate` | Local currency units per 1 USD, joined on `order_date = exchange_date` and `currency_code = currency` |
| `sales_amount_local` | `ROUND(sales_amount_usd × exchange_rate, 2)` |
| `delivery_days` | `delivery_date − order_date` (`NULL` when there is no delivery date) |

## Data Quality

Each table has a data quality checklist (`tests/`). The main findings and the decisions taken:

| Finding | Decision |
|---|---|
| `Customers.csv` is not UTF-8 | Loaded with `ENCODING 'LATIN1'` |
| Prices are text such as `$1,060.22 ` (symbol, thousands comma, trailing space) | Strip `[$,\s]` and cast to `DECIMAL` |
| Dates are text in `M/D/YYYY` format | `TO_DATE(x, 'MM/DD/YYYY')` instead of a `::DATE` cast (independent of `DateStyle`) |
| `Delivery Date` is empty in 79% of the order lines (49,719) | Kept as `NULL`, never filled with a fake value |
| `product_name` repeats the brand (some brands use an abbreviation: `NT`, `SV`, `MGS`, `WWI`), the color and the model code | Removed with `REGEXP_REPLACE` (color and brand stay in their own columns) |
| `state_code` of Napoli customers is `NA` | Kept as the text `'NA'` (never treated as a missing value) |
| `state_code` of United Kingdom customers is the full district name | Kept as is (shortening it created collisions, for example with `NA`) |
| `INITCAP` breaks names such as `McFarland` and states such as `Pays de la Loire` | Not applied to names and states |
| `order_number` repeats across lines of the same order | Duplicates are checked on `(order_number, line_item)`, never on `order_number` alone |
| Store `0` has no square meters | It is the Online store: `NULL` is expected |

Checks performed on every layer: row counts, duplicate keys, unwanted spaces, `NULL` or empty values, invalid dates, price ranges, orphan keys (`NOT EXISTS`) and exchange-rate coverage.

## Repository Structure

> Adjust the folder names to match your repository.

```
electronics-retail-data-warehouse/
├── Datasets/                 # source CSV files
├── docs/
│   └── images/               # architecture, integration, data model and data flow diagrams
├── scripts/
│   ├── bronze/               # DDL + load procedure (bronze.load_bronze)
│   ├── silver/               # DDL + transformation / load scripts
│   └── gold/
│       ├── 00_gold_schema.sql
│       ├── 01_dim_customers.sql
│       ├── 02_dim_products.sql
│       ├── 03_dim_stores.sql
│       ├── 04_dim_date.sql
│       └── 05_fact_sales.sql
├── tests/                    # data quality checklists
└── README.md
```

## How to Run

**Prerequisites:** PostgreSQL, and a database user that can read the CSV files from the server (superuser or the `pg_read_server_files` role).

1. **Create the database and the schemas**
   ```sql
   CREATE SCHEMA IF NOT EXISTS bronze;
   CREATE SCHEMA IF NOT EXISTS silver;
   ```
2. **Bronze:** run the DDL, then create the procedure and load the files.
   Update the file paths inside `bronze.load_bronze()` to the folder where the CSV files are on the database server (the postgres OS user must be able to read it).
   ```sql
   CALL bronze.load_bronze();
   ```
3. **Silver:** run the DDL, then the transformation scripts (`TRUNCATE` + `INSERT ... SELECT`) for the five tables.
4. **Gold:** run the scripts in order. The dimensions can run in any order after `00`; `05_fact_sales.sql` must be last.
   ```
   00_gold_schema.sql
   01_dim_customers.sql   02_dim_products.sql   03_dim_stores.sql   04_dim_date.sql
   05_fact_sales.sql
   ```
   Each Gold script ends with its own checks, which you can run one by one.

> Re-running a dimension script drops `gold.fact_sales` too (`DROP VIEW ... CASCADE`), so re-run `05_fact_sales.sql` afterwards.

## Validation

Expected results after a full run:

| Check | Expected |
|---|---|
| Bronze / Silver rows | customers 15,266 · products 2,517 · stores 67 · sales 62,884 · exchange rates 11,215 |
| Gold dimensions | `dim_customers` 15,266 · `dim_products` 2,517 · `dim_stores` 67 · `dim_date` 2,192 |
| `fact_sales` rows / orders | 62,884 / 26,326 |
| `NULL` keys or exchange rates in `fact_sales` | 0 |
| `delivery_days` | 49,719 `NULL`, the rest between 1 and 17 |
| Total sales (USD) | ≈ 55,755,479.59 |
| Total cost (USD) | ≈ 23,092,791.21 |
| Total profit (USD) | ≈ 32,662,688.38 |
| Online store sales (USD) | ≈ 11,404,324.63 |

## Design Notes and Limitations

- **Prices:** unit price and cost come from the products table (one price per product), not from the price at the time of the sale, so revenue and profit are estimates based on current prices.
- **Surrogate keys** are generated with `ROW_NUMBER()` inside views, so they can change when new data arrives. For production use, build the dimensions as tables with sequences.
- **Full refresh:** every layer is reloaded from scratch (`TRUNCATE` + load); there is no incremental loading.
- **Server-side `COPY`:** the CSV paths are on the database server and need the right permissions.

## Tech Stack

PostgreSQL · PL/pgSQL · SQL

---

*Author: your name here*
