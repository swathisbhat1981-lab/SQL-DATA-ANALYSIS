-- =====================================================================
-- DecodeLabs | Data Analytics | Project 3: SQL Data Analysis
-- Dataset : cleaned_dataset.xlsx  ->  table `orders` (1,200 rows, 14 columns)
-- Dialect : SQLite (runs as-is in DB Browser for SQLite)
--
-- Porting notes
--   MySQL      : strftime('%Y', Date)    -> DATE_FORMAT(Date, '%Y')   (or YEAR(Date))
--                strftime('%Y-%m', Date) -> DATE_FORMAT(Date, '%Y-%m')
--   PostgreSQL : strftime('%Y', Date)    -> TO_CHAR(Date::date, 'YYYY')
--                strftime('%Y-%m', Date) -> TO_CHAR(Date::date, 'YYYY-MM')
--   SQL Server : LIMIT n                 -> SELECT TOP n ...
--   Everything else (SELECT / WHERE / GROUP BY / HAVING / ORDER BY /
--   COUNT / SUM / AVG / CASE / IN / BETWEEN / LIKE) is standard SQL.
--
-- Requirement map (from the project PDF)
--   Write SELECT queries ............ Section 1
--   WHERE ........................... Section 2
--   ORDER BY ........................ Section 3
--   COUNT / SUM / AVG ............... Section 4 and 5
--   GROUP BY ........................ Section 5
--   HAVING (PDF conclusion tip) ..... Section 6
--   % contribution (PDF tip) ........ Query 7.1
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 0 : Create the table (safe to run: does nothing if `orders` already exists,
--           e.g. when you opened orders.db)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    OrderID         TEXT PRIMARY KEY,
    Date            TEXT NOT NULL,      -- stored as 'YYYY-MM-DD'
    CustomerID      TEXT NOT NULL,
    Product         TEXT NOT NULL,
    Quantity        INTEGER NOT NULL,
    UnitPrice       REAL NOT NULL,
    ShippingAddress TEXT,
    PaymentMethod   TEXT,
    OrderStatus     TEXT,
    TrackingNumber  TEXT,
    ItemsInCart     INTEGER,
    CouponCode      TEXT,
    ReferralSource  TEXT,
    TotalPrice      REAL NOT NULL
);

-- Then import cleaned_dataset.xlsx -> File > Save As > CSV, and import the CSV
-- into `orders` (DB Browser: File > Import > Table from CSV file;
-- MySQL Workbench: Table Data Import Wizard; pgAdmin: right-click > Import/Export).


-- =====================================================================
-- SECTION 1: SELECT BASICS
-- =====================================================================

-- 1.1  Preview the table
-- Question : What does the raw data look like?
-- Skills   : SELECT, LIMIT
SELECT *
FROM orders
LIMIT 10;

-- 1.2  Choose specific columns + alias
-- Question : Show only the columns needed for a sales report.
-- Skills   : SELECT, AS (alias)
SELECT OrderID   AS order_id,
       Date      AS order_date,
       Product   AS product,
       Quantity  AS qty,
       TotalPrice AS order_value
FROM orders
LIMIT 10;

-- 1.3  Distinct values
-- Question : Which products do we sell?
-- Skills   : SELECT DISTINCT, ORDER BY
SELECT DISTINCT Product
FROM orders
ORDER BY Product;

-- 1.4  Data-quality check: TotalPrice = Quantity x UnitPrice
-- Question : Is the TotalPrice column trustworthy? (0 rows = every order reconciles)
-- Skills   : SELECT, WHERE, calculated column
SELECT OrderID,
       Quantity,
       UnitPrice,
       ROUND(Quantity * UnitPrice, 2) AS calculated_total,
       TotalPrice
FROM orders
WHERE ROUND(Quantity * UnitPrice, 2) <> ROUND(TotalPrice, 2);

-- 1.5  Data-quality check: duplicate OrderIDs
-- Question : Does any OrderID appear more than once? (0 rows = all unique)
-- Skills   : GROUP BY, HAVING, COUNT
SELECT OrderID, COUNT(*) AS times_seen
FROM orders
GROUP BY OrderID
HAVING COUNT(*) > 1;


-- =====================================================================
-- SECTION 2: WHERE FILTERING
-- =====================================================================

-- 2.1  Equality filter
-- Question : List all delivered orders.
-- Skills   : WHERE, =
SELECT OrderID, Date, Product, Quantity, TotalPrice
FROM orders
WHERE OrderStatus = 'Delivered'
ORDER BY Date;

-- 2.2  Numeric comparison
-- Question : Which orders are worth 3,000 or more?
-- Skills   : WHERE, >=
SELECT OrderID, Date, Product, Quantity, UnitPrice, TotalPrice
FROM orders
WHERE TotalPrice >= 3000
ORDER BY TotalPrice DESC;

-- 2.3  Combining conditions (AND)
-- Question : Which delivered orders are high-value (2,000+)?
-- Skills   : WHERE, AND
SELECT OrderID, Date, Product, PaymentMethod, TotalPrice
FROM orders
WHERE OrderStatus = 'Delivered'
  AND TotalPrice >= 2000
ORDER BY TotalPrice DESC;

-- 2.4  IN + BETWEEN
-- Question : Which 2024 orders were for Laptops, Phones or Tablets?
-- Skills   : WHERE, IN, BETWEEN, AND
SELECT OrderID, Date, Product, TotalPrice
FROM orders
WHERE Product IN ('Laptop', 'Phone', 'Tablet')
  AND Date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY Date;

-- 2.5  Pattern matching (LIKE)
-- Question : Which orders used a 'SAVE' coupon (SAVE10)?
-- Skills   : WHERE, LIKE, wildcard %
SELECT OrderID, Date, Product, CouponCode, TotalPrice
FROM orders
WHERE CouponCode LIKE 'SAVE%'
ORDER BY Date;

-- 2.6  Negation (<>) and OR
-- Question : Which orders were lost (Cancelled OR Returned)?
-- Skills   : WHERE, OR, IN
SELECT OrderID, Date, Product, OrderStatus, TotalPrice
FROM orders
WHERE OrderStatus = 'Cancelled'
   OR OrderStatus = 'Returned'
ORDER BY TotalPrice DESC;


-- =====================================================================
-- SECTION 3: ORDER BY SORTING
-- =====================================================================

-- 3.1  Top 10 orders by value
-- Question : What are our 10 biggest orders?
-- Skills   : ORDER BY DESC, LIMIT
SELECT OrderID, Date, Product, Quantity, TotalPrice
FROM orders
ORDER BY TotalPrice DESC
LIMIT 10;

-- 3.2  Multi-column sort
-- Question : Sort by product A-Z, and within each product by value (highest first).
-- Skills   : ORDER BY with two columns
SELECT Product, OrderID, TotalPrice
FROM orders
ORDER BY Product ASC, TotalPrice DESC
LIMIT 20;

-- 3.3  Most recent orders
-- Question : What are the 10 latest orders?
-- Skills   : ORDER BY DESC on a date
SELECT OrderID, Date, Product, OrderStatus, TotalPrice
FROM orders
ORDER BY Date DESC
LIMIT 10;


-- =====================================================================
-- SECTION 4: AGGREGATIONS
-- =====================================================================

-- 4.1  Overall KPIs
-- Question : How big is the business overall?
-- Skills   : COUNT, SUM, AVG, MIN, MAX
SELECT COUNT(*)                    AS total_orders,
       COUNT(DISTINCT CustomerID)  AS unique_customers,
       SUM(Quantity)               AS units_sold,
       ROUND(SUM(TotalPrice), 2)   AS gross_revenue,
       ROUND(AVG(TotalPrice), 2)   AS avg_order_value,
       MIN(TotalPrice)             AS smallest_order,
       MAX(TotalPrice)             AS largest_order,
       MIN(Date)                   AS first_order_date,
       MAX(Date)                   AS last_order_date
FROM orders;

-- 4.2  COUNT(*) vs COUNT(column)
-- Question : Does any column contain NULLs? (PDF 'Crucial Rule': COUNT(*) counts every row, COUNT(col) skips NULLs)
-- Skills   : COUNT(*), COUNT(col), NULL handling
SELECT COUNT(*)            AS all_rows,
       COUNT(CouponCode)   AS non_null_coupon,
       COUNT(TotalPrice)   AS non_null_total,
       COUNT(CustomerID)   AS non_null_customer
FROM orders;


-- =====================================================================
-- SECTION 5: GROUP BY
-- =====================================================================

-- 5.1  Orders by status
-- Question : How many orders are in each status?
-- Skills   : GROUP BY, COUNT, ORDER BY alias
SELECT OrderStatus,
       COUNT(*) AS order_count
FROM orders
GROUP BY OrderStatus
ORDER BY order_count DESC;

-- 5.2  Product performance
-- Question : Which product brings in the most revenue?
-- Skills   : GROUP BY, COUNT, SUM, AVG
SELECT Product,
       COUNT(*)                   AS orders,
       SUM(Quantity)              AS units_sold,
       ROUND(SUM(TotalPrice), 2)  AS total_revenue,
       ROUND(AVG(TotalPrice), 2)  AS avg_order_value
FROM orders
GROUP BY Product
ORDER BY total_revenue DESC;

-- 5.3  Payment method analysis
-- Question : Which payment method is most used, and which has the highest average order?
-- Skills   : GROUP BY, COUNT, AVG
SELECT PaymentMethod,
       COUNT(*)                   AS orders,
       ROUND(SUM(TotalPrice), 2)  AS total_revenue,
       ROUND(AVG(TotalPrice), 2)  AS avg_order_value
FROM orders
GROUP BY PaymentMethod
ORDER BY orders DESC;

-- 5.4  Marketing channel analysis
-- Question : Which referral source drives the most revenue?
-- Skills   : GROUP BY, COUNT, SUM, AVG
SELECT ReferralSource,
       COUNT(*)                   AS orders,
       ROUND(SUM(TotalPrice), 2)  AS total_revenue,
       ROUND(AVG(TotalPrice), 2)  AS avg_order_value
FROM orders
GROUP BY ReferralSource
ORDER BY total_revenue DESC;

-- 5.5  Coupon effectiveness
-- Question : Do coupons change order size?
-- Skills   : GROUP BY, COUNT, SUM, AVG
SELECT CouponCode,
       COUNT(*)                   AS orders,
       ROUND(SUM(TotalPrice), 2)  AS total_revenue,
       ROUND(AVG(TotalPrice), 2)  AS avg_order_value,
       ROUND(AVG(ItemsInCart), 2) AS avg_items_in_cart
FROM orders
GROUP BY CouponCode
ORDER BY avg_order_value DESC;

-- 5.6  Yearly revenue
-- Question : How does revenue compare year to year?
-- Skills   : GROUP BY on a date expression (strftime)
SELECT strftime('%Y', Date)       AS year,
       COUNT(*)                   AS orders,
       ROUND(SUM(TotalPrice), 2)  AS total_revenue
FROM orders
GROUP BY strftime('%Y', Date)
ORDER BY year;

-- 5.7  Monthly revenue trend
-- Question : What does the month-by-month revenue trend look like?
-- Skills   : GROUP BY on a date expression, ORDER BY
SELECT strftime('%Y-%m', Date)    AS year_month,
       COUNT(*)                   AS orders,
       ROUND(SUM(TotalPrice), 2)  AS total_revenue
FROM orders
GROUP BY strftime('%Y-%m', Date)
ORDER BY year_month;

-- 5.8  Two-column GROUP BY
-- Question : How many orders does each product have in each status?
-- Skills   : GROUP BY two columns
SELECT Product,
       OrderStatus,
       COUNT(*) AS orders
FROM orders
GROUP BY Product, OrderStatus
ORDER BY Product, orders DESC;


-- =====================================================================
-- SECTION 6: HAVING
-- =====================================================================

-- 6.1  Repeat customers
-- Question : Which customers placed more than one order?
-- Skills   : GROUP BY, HAVING, COUNT
SELECT CustomerID,
       COUNT(*)                   AS orders,
       ROUND(SUM(TotalPrice), 2)  AS total_spent
FROM orders
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY orders DESC, total_spent DESC;

-- 6.2  Filter groups by an aggregate
-- Question : Which months earned more than 50,000 in revenue?
-- Skills   : GROUP BY, HAVING SUM
SELECT strftime('%Y-%m', Date)    AS year_month,
       ROUND(SUM(TotalPrice), 2)  AS total_revenue
FROM orders
GROUP BY strftime('%Y-%m', Date)
HAVING SUM(TotalPrice) > 50000
ORDER BY total_revenue DESC;

-- 6.3  WHERE + GROUP BY + HAVING together
-- Question : Among DELIVERED orders only, which products average more than 1,000 per order?
-- Skills   : WHERE (row filter) then HAVING (group filter)
SELECT Product,
       COUNT(*)                   AS delivered_orders,
       ROUND(AVG(TotalPrice), 2)  AS avg_order_value
FROM orders
WHERE OrderStatus = 'Delivered'
GROUP BY Product
HAVING AVG(TotalPrice) > 1000
ORDER BY avg_order_value DESC;


-- =====================================================================
-- SECTION 7: BUSINESS INSIGHTS
-- =====================================================================

-- 7.1  Percentage contribution by product
-- Question : What share of total revenue does each product contribute? (PDF conclusion suggests this)
-- Skills   : GROUP BY, SUM, scalar subquery, percentage
SELECT Product,
       ROUND(SUM(TotalPrice), 2) AS product_revenue,
       ROUND(100.0 * SUM(TotalPrice) / (SELECT SUM(TotalPrice) FROM orders), 2) AS pct_of_total
FROM orders
GROUP BY Product
ORDER BY product_revenue DESC;

-- 7.2  Cancellation & return rate by product
-- Question : Which product loses the most orders to cancellations or returns?
-- Skills   : GROUP BY, SUM(CASE WHEN ...), rate calculation
SELECT Product,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
       SUM(CASE WHEN OrderStatus = 'Returned'  THEN 1 ELSE 0 END) AS returned,
       ROUND(100.0 * SUM(CASE WHEN OrderStatus IN ('Cancelled','Returned') THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS lost_order_pct
FROM orders
GROUP BY Product
ORDER BY lost_order_pct DESC;

-- 7.3  Gross vs net revenue by product
-- Question : How much revenue is at risk? Net = orders that are NOT Cancelled or Returned.
-- Skills   : GROUP BY, conditional SUM, CASE WHEN
SELECT Product,
       ROUND(SUM(TotalPrice), 2) AS gross_revenue,
       ROUND(SUM(CASE WHEN OrderStatus NOT IN ('Cancelled','Returned')
                      THEN TotalPrice ELSE 0 END), 2) AS net_revenue,
       ROUND(SUM(CASE WHEN OrderStatus IN ('Cancelled','Returned')
                      THEN TotalPrice ELSE 0 END), 2) AS revenue_lost
FROM orders
GROUP BY Product
ORDER BY net_revenue DESC;

-- 7.4  Top 3 referral sources by delivered revenue
-- Question : Which 3 marketing channels deliver the most completed (Delivered) revenue?
-- Skills   : WHERE, GROUP BY, SUM, ORDER BY, LIMIT
SELECT ReferralSource,
       COUNT(*)                   AS delivered_orders,
       ROUND(SUM(TotalPrice), 2)  AS delivered_revenue
FROM orders
WHERE OrderStatus = 'Delivered'
GROUP BY ReferralSource
ORDER BY delivered_revenue DESC
LIMIT 3;

-- 7.5  The 'Alias Trap' done correctly (PDF slide 12)
-- Question : Filter on a computed value. Using the alias in WHERE fails because WHERE runs before SELECT; wrap it in a subquery instead.
-- Skills   : Execution order, alias, subquery
-- WRONG in MySQL / PostgreSQL / SQL Server (error: column "rev" does not exist),
-- because WHERE runs before SELECT. (SQLite is lenient and allows it, so don't rely on that.)
--   SELECT Quantity * UnitPrice AS rev FROM orders WHERE rev > 3000;

-- RIGHT option A: repeat the expression inside WHERE
--   SELECT Quantity * UnitPrice AS rev FROM orders WHERE Quantity * UnitPrice > 3000;

-- RIGHT option B (used below): compute the alias in a subquery, filter it in the outer query
SELECT *
FROM (
    SELECT OrderID, Product, Quantity * UnitPrice AS rev
    FROM orders
) AS t
WHERE rev > 3000
ORDER BY rev DESC;
