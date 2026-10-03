-- =====================================================================
 ANALYTICS, AGGREGATIONS & ADVANCED SQL QUERIES
-- =====================================================================

-- ---------------------------------------------------------------------
-- Task 1: Overall Business KPIs (Total Sales, Orders, Customers, Products, Quantity, Profit)
-- ---------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(DISTINCT f.customer_key) AS total_customers,
    COUNT(DISTINCT f.product_key) AS total_products,
    SUM(f.quantity) AS total_quantity_sold,
    ROUND(SUM(f.net_sales), 2) AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit
FROM dw.fact_product_sales f;


-- ---------------------------------------------------------------------
-- Task 2: Monthly Aggregations (Sales, Orders, Quantity, Profit)
-- ---------------------------------------------------------------------
SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.quantity) AS total_quantity,
    ROUND(SUM(f.net_sales), 2) AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit
FROM dw.fact_product_sales f
JOIN dw.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ---------------------------------------------------------------------
-- Task 3: Sales by Category, Department, Product, and Customer
-- ---------------------------------------------------------------------
-- 1. Sales by Category
SELECT 
    c.category_name,
    ROUND(SUM(ps.net_sales), 2) AS total_sales,
    SUM(ps.quantity) AS total_quantity
FROM dw.fact_product_sales ps
JOIN dw.dim_product p ON ps.product_key = p.product_key
JOIN dw.dim_category c ON p.category_key = c.category_key
GROUP BY c.category_name
ORDER BY total_sales DESC;

-- 2. Sales by Department
SELECT 
    dept.department_name,
    ROUND(SUM(ps.net_sales), 2) AS total_sales,
    SUM(ps.quantity) AS total_quantity
FROM dw.fact_product_sales ps
JOIN dw.dim_product p ON ps.product_key = p.product_key
JOIN dw.dim_department dept ON p.department_key = dept.department_key
GROUP BY dept.department_name
ORDER BY total_sales DESC;

-- 3. Sales by Product
SELECT 
    p.product_name,
    p.brand,
    ROUND(SUM(ps.net_sales), 2) AS total_sales,
    SUM(ps.quantity) AS total_quantity
FROM dw.fact_product_sales ps
JOIN dw.dim_product p ON ps.product_key = p.product_key
GROUP BY p.product_name, p.brand
ORDER BY total_sales DESC;

-- 4. Sales by Customer
SELECT 
    cust.customer_id,
    CONCAT(cust.first_name, ' ', cust.last_name) AS customer_name,
    cust.country,
    ROUND(SUM(cs.sales), 2) AS total_sales,
    SUM(cs.order_count) AS total_orders
FROM dw.fact_customer_sales cs
JOIN dw.dim_customer cust ON cs.customer_key = cust.customer_key
GROUP BY cust.customer_id, cust.first_name, cust.last_name, cust.country
ORDER BY total_sales DESC;


-- ---------------------------------------------------------------------
-- Task 4: Top 10 Products by Sales
-- ---------------------------------------------------------------------
SELECT 
    p.product_name,
    p.brand,
    ROUND(SUM(ps.net_sales), 2) AS total_sales
FROM dw.fact_product_sales ps
JOIN dw.dim_product p ON ps.product_key = p.product_key
GROUP BY p.product_name, p.brand
ORDER BY total_sales DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Task 5: Top 10 Customers by Total Spending
-- ---------------------------------------------------------------------
SELECT 
    cust.customer_id,
    CONCAT(cust.first_name, ' ', cust.last_name) AS customer_name,
    cust.country,
    ROUND(SUM(cs.sales), 2) AS total_spending
FROM dw.fact_customer_sales cs
JOIN dw.dim_customer cust ON cs.customer_key = cust.customer_key
GROUP BY cust.customer_id, cust.first_name, cust.last_name, cust.country
ORDER BY total_spending DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Task 6: Average Order Value (AOV)
-- ---------------------------------------------------------------------
SELECT 
    ROUND(SUM(net_sales) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM dw.fact_order_detail;


-- ---------------------------------------------------------------------
-- Task 7: Order Status Analysis (Count & Value)
-- ---------------------------------------------------------------------
SELECT 
    os.order_status_name,
    COUNT(DISTINCT fo.order_id) AS order_count,
    ROUND(SUM(fo.total_amount), 2) AS total_order_value
FROM dw.fact_order fo
JOIN dw.dim_order_status os ON fo.order_status_key = os.order_status_key
GROUP BY os.order_status_name
ORDER BY order_count DESC;


-- ---------------------------------------------------------------------
-- Task 8: Payment Methods Analysis
-- ---------------------------------------------------------------------
SELECT 
    pm.payment_method_name,
    COUNT(fp.payment_id) AS transaction_count,
    ROUND(SUM(fp.amount), 2) AS total_payment_amount,
    ROUND(AVG(fp.amount), 2) AS avg_payment_amount
FROM dw.fact_payment fp
JOIN dw.dim_payment_method pm ON fp.payment_method_key = pm.payment_method_key
GROUP BY pm.payment_method_name
ORDER BY total_payment_amount DESC;


-- ---------------------------------------------------------------------
-- Task 9: Shipment Performance Analysis
-- ---------------------------------------------------------------------
SELECT 
    s.company_name AS shipper_name,
    COUNT(fs.shipment_id) AS total_shipments,
    ROUND(AVG(fs.delivery_days), 2) AS avg_delivery_days,
    MIN(fs.delivery_days) AS min_delivery_days,
    MAX(fs.delivery_days) AS max_delivery_days
FROM dw.fact_shipment fs
JOIN dw.dim_shipper s ON fs.shipper_key = s.shipper_key
WHERE fs.delivery_days IS NOT NULL
GROUP BY s.company_name
ORDER BY avg_delivery_days ASC;

-- ---------------------------------------------------------------------
-- Task 10: Running Sales (Cumulative Sales by Date)
-- ---------------------------------------------------------------------
SELECT 
    d.full_date,
    ROUND(SUM(ps.net_sales), 2) AS daily_sales,
    ROUND(
        SUM(SUM(ps.net_sales)) OVER (ORDER BY d.full_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 
        2
    ) AS cumulative_sales
FROM dw.fact_product_sales ps
JOIN dw.dim_date d ON ps.date_key = d.date_key
GROUP BY d.full_date
ORDER BY d.full_date;


-- ---------------------------------------------------------------------
-- Task 11: Month-over-Month (MoM) Growth Analysis
-- ---------------------------------------------------------------------
WITH MonthlyRevenue AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        ROUND(SUM(ps.net_sales), 2) AS current_month_sales
    FROM dw.fact_product_sales ps
    JOIN dw.dim_date d ON ps.date_key = d.date_key
    GROUP BY d.year, d.month, d.month_name
)
SELECT 
    year,
    month_name,
    current_month_sales,
    LAG(current_month_sales, 1) OVER (ORDER BY year, month) AS previous_month_sales,
    ROUND(current_month_sales - LAG(current_month_sales, 1) OVER (ORDER BY year, month), 2) AS sales_difference,
    ROUND(
        ((current_month_sales - LAG(current_month_sales, 1) OVER (ORDER BY year, month)) 
        / NULLIF(LAG(current_month_sales, 1) OVER (ORDER BY year, month), 0)) * 100, 
        2
    ) AS growth_percentage
FROM MonthlyRevenue
ORDER BY year, month;


-- ---------------------------------------------------------------------
-- Task 12: Top 3 Products by Sales within Each Category (Window Ranking)
-- ---------------------------------------------------------------------
WITH ProductSalesByCategory AS (
    SELECT 
        c.category_name,
        p.product_name,
        ROUND(SUM(ps.net_sales), 2) AS sales,
        DENSE_RANK() OVER (PARTITION BY c.category_name ORDER BY SUM(ps.net_sales) DESC) as rank
    FROM dw.fact_product_sales ps
    JOIN dw.dim_product p ON ps.product_key = p.product_key
    JOIN dw.dim_category c ON p.category_key = c.category_key
    GROUP BY c.category_name, p.product_name
)
SELECT 
    category_name AS category,
    product_name AS product,
    sales,
    rank
FROM ProductSalesByCategory
WHERE rank <= 3
ORDER BY category_name, rank;


-- ---------------------------------------------------------------------
-- Task 13: Customer Ranking by Total Spending and Order Count
-- ---------------------------------------------------------------------
SELECT 
    CONCAT(cust.first_name, ' ', cust.last_name) AS customer,
    ROUND(SUM(cs.sales), 2) AS total_spending,
    SUM(cs.order_count) AS order_count,
    DENSE_RANK() OVER (ORDER BY SUM(cs.sales) DESC) AS rank
FROM dw.fact_customer_sales cs
JOIN dw.dim_customer cust ON cs.customer_key = cust.customer_key
GROUP BY cust.first_name, cust.last_name
ORDER BY rank;
