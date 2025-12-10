CREATE DATABASE gamezone;
USE gamezone;

-- Create orders table
CREATE TABLE region (
	country_code VARCHAR(2) PRIMARY KEY,
    region VARCHAR(50) NOT NULL
);

-- Create orders table
CREATE TABLE orders (
    user_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) PRIMARY KEY,
    purchase_ts DATETIME,
    ship_ts DATETIME,
    purchase_year INT,
    purchase_month INT,
    time_to_ship INT,
    product_name VARCHAR(255),
    product_id VARCHAR(50),
    usd_price DECIMAL(10, 2),
    purchase_platform VARCHAR(50),
    marketing_channel VARCHAR(100),
    account_creation_method VARCHAR(100),
    country_code VARCHAR(2),
    region VARCHAR(50),
    
    -- Indexes for faster queries
    INDEX idx_user_id (user_id),
    INDEX idx_purchase_date (purchase_year, purchase_month),
    INDEX idx_product (product_name),
    INDEX idx_country (country_code)
);

TRUNCATE TABLE region;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/region.csv'
INTO TABLE region
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(country_code, region);

TRUNCATE TABLE orders;
ALTER TABLE orders DROP COLUMN time_to_ship;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
IGNORE
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(user_id, order_id, @purchase_date, @ship_date, @purchase_year_str, @purchase_month_str, @dummy, product_name, product_id, @usd_price_str, purchase_platform, marketing_channel, account_creation_method, country_code, region)
SET purchase_ts = IF(@purchase_date = 'Missing Date', NULL, STR_TO_DATE(@purchase_date, '%m/%d/%y %H:%i')),
    ship_ts = IF(@ship_date = 'Missing Date', NULL, STR_TO_DATE(@ship_date, '%m/%d/%y %H:%i')),
    purchase_year = NULLIF(@purchase_year_str, ''),
    purchase_month = NULLIF(@purchase_month_str, ''),
    usd_price = IF(@usd_price_str = 'Missing Price', NULL, @usd_price_str);

-- Verify and check
SELECT COUNT(*) 
FROM region;

SELECT COUNT(*)
FROM orders;
 
SELECT 
    COUNT(*) as total_rows,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as null_user_ids,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) as null_order_ids,
    SUM(CASE WHEN usd_price IS NULL THEN 1 ELSE 0 END) as null_prices,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) as null_products
FROM orders;

SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(DISTINCT user_id) as unique_customers,
    MIN(purchase_year) as earliest_year,
    MAX(purchase_year) as latest_year,
    COUNT(DISTINCT product_name) as product_count,
    COUNT(DISTINCT country_code) as country_count
FROM orders;

SELECT 
    COUNT(*) as total_rows,
    SUM(CASE WHEN user_id IS NULL OR user_id = '' THEN 1 ELSE 0 END) as missing_user_id,
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) as missing_order_id,
    SUM(CASE WHEN product_name IS NULL OR product_name = '' THEN 1 ELSE 0 END) as missing_product,
    SUM(CASE WHEN usd_price IS NULL THEN 1 ELSE 0 END) as missing_price,
    SUM(CASE WHEN purchase_year IS NULL THEN 1 ELSE 0 END) as missing_year,
    SUM(CASE WHEN purchase_month IS NULL THEN 1 ELSE 0 END) as missing_month,
    SUM(CASE WHEN country_code IS NULL OR country_code = '' THEN 1 ELSE 0 END) as missing_country,
    SUM(CASE WHEN marketing_channel IS NULL OR marketing_channel = '' THEN 1 ELSE 0 END) as missing_channel,
    SUM(CASE WHEN purchase_platform IS NULL OR purchase_platform = '' THEN 1 ELSE 0 END) as missing_platform,
    SUM(CASE WHEN account_creation_method IS NULL OR account_creation_method = '' THEN 1 ELSE 0 END) as missing_creation_method,
    ROUND(100.0 * SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_missing_user
FROM orders;

-- Data completeness check
SELECT 
    'user_id' as column_name,
    COUNT(*) as total,
    COUNT(user_id) as non_null,
    ROUND(100.0 * COUNT(user_id) / COUNT(*), 2) as completeness_pct
FROM orders
UNION ALL
SELECT 'product_name', COUNT(*), COUNT(product_name), ROUND(100.0 * COUNT(product_name) / COUNT(*), 2) FROM orders
UNION ALL
SELECT 'usd_price', COUNT(*), COUNT(usd_price), ROUND(100.0 * COUNT(usd_price) / COUNT(*), 2) FROM orders
UNION ALL
SELECT 'country_code', COUNT(*), COUNT(country_code), ROUND(100.0 * COUNT(country_code) / COUNT(*), 2) FROM orders
UNION ALL
SELECT 'marketing_channel', COUNT(*), COUNT(marketing_channel), ROUND(100.0 * COUNT(marketing_channel) / COUNT(*), 2) FROM orders;

-- Data quality issues
SELECT 
    MIN(usd_price) as min_price,
    MAX(usd_price) as max_price,
    AVG(usd_price) as avg_price,
    STDDEV(usd_price) as stddev_price
FROM orders;

SELECT 
    'Zero or negative prices' as issue,
    COUNT(*) as count
FROM orders 
WHERE usd_price <= 0
UNION ALL
SELECT 
    'Extremely high prices (>$1000)',
    COUNT(*)
FROM orders 
WHERE usd_price > 1000;

-- Verify relationships
SELECT 
    o.country_code,
    COUNT(*) as order_count,
    MAX(r.region) as region_exists
FROM orders o
LEFT JOIN region r ON o.country_code = r.country_code
GROUP BY o.country_code
HAVING region_exists IS NULL
ORDER BY order_count DESC;

SELECT 
    o.country_code,
    r.region,
    COUNT(*) as orders,
    SUM(usd_price) as revenue
FROM orders o
LEFT JOIN region r ON o.country_code = r.country_code
GROUP BY o.country_code, r.region
ORDER BY orders DESC
LIMIT 15; -- Countries with most orders
