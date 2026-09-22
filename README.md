# Project 3: SQL Data Analysis

**DecodeLabs Industrial Training Kit | Data Analytics | Batch 2026**

Author: _add your name here_

## Overview
SQL analysis of an e-commerce orders dataset (1,200 orders, 1,189 customers, 2023-01-01 to 2025-06-30).
The project covers `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING` and the `COUNT` / `SUM` / `AVG` aggregations, plus
percentage-contribution and conditional-aggregation queries.

## Repository structure
```
Project3_SQL_Data_Analysis/
|-- README.md
|-- report/     Project3_SQL_Data_Analysis_Report.pdf   <- full report (queries, results, insights, charts)
|-- sql/        Project3_SQL_Queries.sql                <- all 32 commented queries
|-- data/       cleaned_dataset.xlsx                    <- source data
|-- database/   orders.db                               <- SQLite database (table: orders)
|-- results/    Project3_SQL_Analysis.xlsx              <- query results, insights, Excel cross-check
`-- images/     charts used in the report
```

## How to run
1. Install [DB Browser for SQLite](https://sqlitebrowser.org/) and open `database/orders.db`.
2. Open the **Execute SQL** tab and load `sql/Project3_SQL_Queries.sql`.
3. Highlight a single query and press **Ctrl+Enter** to run it.

For MySQL / PostgreSQL, import the data into a table named `orders` and replace `strftime()` as described at the top of the `.sql` file.

## Key findings
- **Scale:** 1,200 orders from 1,189 customers between 2023-01-01 and 2025-06-30; gross revenue 1,264,761.96, average order value 1,053.97. (4.1)
- **Order outcomes:** Only 231 of 1,200 orders (19.2%) are Delivered. Cancelled (250) + Returned (247) = 497 orders, or 41.4% of all orders - status is spread almost evenly across all five values. (5.1)
- **Revenue at risk:** Excluding Cancelled and Returned orders, net revenue is 745,088.05 versus gross 1,264,761.96 (58.9% retained). Note this still includes Pending and Shipped orders. (7.3)
- **Products:** Revenue is spread fairly evenly: Chair leads with 15.47% of total and Phone is lowest with 12.00%. Monitor has the highest cancel/return rate (43.56%). (5.2, 7.1, 7.2)
- **Payment & channel:** Credit Card has the highest average order value (1,127.55). Instagram is the top referral source by total revenue, while Email leads on Delivered revenue only. (5.3, 5.4, 7.4)
- **Coupons:** Average order value differs only between 1,035.90 and 1,070.41 across coupon groups, so coupons show no clear order-size uplift in this data. (5.5)
- **Trend:** Yearly revenue: 2023 = 552,643.24, 2024 = 480,235.87, 2025 = 231,882.85. 2025 only covers Jan-Jun, so compare like-for-like: H1 2023 = 286,501.52, H1 2024 = 257,059.34, H1 2025 = 231,882.85. (5.6, 5.7)
- **Customers:** Only 11 customers appear more than once (all with exactly 2 orders), so repeat purchasing is very low. (6.1)
- **Data quality:** No duplicate OrderIDs, no NULLs in any checked column, and TotalPrice equals Quantity x UnitPrice on every row. (1.4, 1.5, 4.2)

## Requirement coverage
| Requirement | Queries |
|---|---|
| SELECT | Section 1 |
| WHERE, ORDER BY | Sections 2 and 3 |
| COUNT, SUM, AVG, GROUP BY | Sections 4 and 5 |
| HAVING, percentage contribution | Section 6, query 7.1 |
