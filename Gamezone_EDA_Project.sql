USE gamezone;

-- I. Univariate Analysis
-- 1. Price Statistics
SELECT COUNT(*), MIN(usd_price) AS min,
	MAX(usd_price) AS max,
    AVG(usd_price) AS average,
    STDDEV(usd_price) AS st_dev,
    VARIANCE(usd_price) AS var
FROM orders;

-- 2. Price Distribution by Bin
SELECT CASE 
	WHEN usd_price < 50 THEN '$0-50'
	WHEN usd_price < 100 THEN '$50-100'
	WHEN usd_price < 150 THEN '$100-150'
	WHEN usd_price < 200 THEN '$150-200'
	WHEN usd_price < 300 THEN '$200-300'
	WHEN usd_price < 500 THEN '$300-500'
	ELSE '$500+' 
END AS price_range,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage,
    SUM(usd_price) AS total_revenue,
    AVG(usd_price) AS avg_price_in_range
FROM orders
GROUP BY price_range
ORDER BY CASE 
    WHEN price_range = '$0-50' THEN 1
    WHEN price_range = '$50-100' THEN 2
    WHEN price_range = '$100-150' THEN 3
    WHEN price_range = '$150-200' THEN 4
    WHEN price_range = '$200-300' THEN 5
    WHEN price_range = '$300-500' THEN 6
    ELSE 7
  END;
/* $150-200 is the most purchased range with 37.36%. The least is $200-300 with 1.44% */

-- 3. Product Distribution
SELECT product_name, COUNT(*) AS order_count, SUM(usd_price) AS total_revenue, AVG(usd_price) AS avg_price, MIN(usd_price) AS min_price, MAX(usd_price) AS max_price
FROM orders
GROUP BY product_name
ORDER BY order_count DESC; 
/* Each product has some suspicious minimum price that below the retail price, such as Nintendo with $33. Products that has strange 
minimum prices are Nintendo Switch, Sony Playstation 5 Bundle, Lenovo IdeaPad Gaming 3, Acer Nitro V Gaming Laptop, Razer Pro Gaming Headset */

SELECT o.*
FROM orders o
INNER JOIN (SELECT product_name, MIN(usd_price) AS min_price
FROM orders
GROUP BY product_name) min_prices
ON o.product_name = min_prices.product_name
AND o.usd_price = min_prices.min_price
ORDER BY o.product_name, o.purchase_ts; 
/* Double check the price distribution with find the cheapest orders for each product. There are 39 orders that has 0.00 in price,
including strangely low prices */

-- 4. Geographic Distribution
SELECT r.region, COUNT(*) AS order_count, COUNT(DISTINCT o.user_id) AS customers, COUNT(DISTINCT o.country_code) AS countries_in_region,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_orders
FROM orders o
LEFT JOIN region r ON o.country_code = r.country_code
GROUP BY r.region
ORDER BY order_count DESC; 
/* Quite evenly all around the world besides 51% in NA, the rest is 30% at EMEA and 11.78% in APAC. Others are at LATAM and missing values */

SELECT o.country_code, r.region, COUNT(*) AS orders, SUM(o.usd_price) AS total_revenue, AVG(o.usd_price) AS avg_order, COUNT(DISTINCT o.user_id) AS customers
FROM orders o
LEFT JOIN region r ON o.country_code = r.country_code
GROUP BY o.country_code, r.region
ORDER BY orders DESC
LIMIT 10; -- Top countries: US, GB, CA, AU, DE, FR, JP, BR, ES, NL

-- 5. Marketing Channel Distribution
SELECT marketing_channel, COUNT(*) AS orders, COUNT(DISTINCT user_id) AS customers, AVG(usd_price) AS avg_order_value
FROM orders
GROUP BY marketing_channel
ORDER BY orders DESC; 
/* direct > email > affiliate > social media > unknown */

-- 6. Platform Distribution
SELECT purchase_platform, COUNT(*) AS orders, COUNT(DISTINCT user_id) AS customers,
SUM(usd_price) AS total_revenue, AVG(usd_price) AS avg_order_value
FROM orders
GROUP BY purchase_platform
ORDER BY orders DESC; -- Order purchases through website is 9 times through mobile app

-- 7. Account Creation Method
SELECT account_creation_method, COUNT(*) AS orders, COUNT(DISTINCT user_id) AS customers,
SUM(usd_price) AS total_revenue
FROM orders
GROUP BY account_creation_method
ORDER BY orders DESC; -- desktop > mobile > unknown > tablet > tv

-- II. Time Series Analysis
-- 1. Monthly trends
SELECT purchase_year, purchase_month, COUNT(DISTINCT user_id) AS customers, COUNT(*) AS orders, SUM(usd_price) AS total_revenue
FROM orders
WHERE purchase_year != 0
AND purchase_month != 0
GROUP BY purchase_year, purchase_month
ORDER BY purchase_year, purchase_month;

SELECT purchase_year, purchase_month, COUNT(DISTINCT user_id) AS customers, SUM(usd_price) AS revenue, COUNT(*) AS orders
FROM orders
WHERE purchase_year = '2019'
GROUP BY purchase_year, purchase_month
ORDER BY orders DESC; 
/* In 2019, months that have high orders are 12 > 9 > 11 > 8 > 7
In 2020, 12 > 9 > 11 > 5 > 8
In 2021, 1 and 2 */

-- 2. Average performance by month (across all years)
SELECT purchase_month, COUNT(*) AS total_orders, ROUND(AVG(monthly_orders), 2) AS avg_monthly_orders,
ROUND(AVG(monthly_revenue), 2) AS avg_monthly_revenue,
ROUND(AVG(avg_order_value), 2) AS avg_order_value
FROM (SELECT purchase_year, purchase_month, COUNT(*) AS monthly_orders, SUM(usd_price) AS monthly_revenue, AVG(usd_price) AS avg_order_value
    FROM orders
    GROUP BY purchase_year, purchase_month) monthly_data
WHERE purchase_month != 0
GROUP BY purchase_month
ORDER BY purchase_month; 

-- 3. Best and Worst performing months
WITH monthly_stats AS (SELECT purchase_year, purchase_month, COUNT(*) AS orders, SUM(usd_price) AS revenue 
    FROM orders 
    WHERE purchase_month != 0  -- Filter out month 0
    GROUP BY purchase_year, purchase_month)
(SELECT 'Best Month' AS metric, purchase_year, purchase_month, orders, revenue 
	FROM monthly_stats 
	ORDER BY revenue DESC 
	LIMIT 1)
UNION ALL
(SELECT 'Worst Month' AS metric, purchase_year, purchase_month, orders, revenue 
	FROM monthly_stats 
	ORDER BY revenue ASC 
	LIMIT 1); -- Best month is 12 in 2020 with revenue of 5.5mil and worst month is 2 in 2019 with revenue of 80k

-- III. Customer Analysis
-- 1. Customer purchase frequency distribution
SELECT CASE 
	WHEN order_count = 1 THEN 'One-time buyers'
	WHEN order_count = 2 THEN 'Two purchases'
	WHEN order_count BETWEEN 3 AND 5 THEN '3-5 purchases'
	WHEN order_count BETWEEN 6 AND 10 THEN '6-10 purchases'
	ELSE '11+ purchases'
END AS customer_segment, COUNT(*) AS customer_count, SUM(total_spent) AS total_revenue  
FROM (SELECT user_id, COUNT(*) AS order_count, SUM(usd_price) AS total_spent
    FROM orders
    GROUP BY user_id) customer_summary
GROUP BY customer_segment
ORDER BY CASE customer_segment
  WHEN 'One-time buyers' THEN 1
  WHEN 'Two purchases' THEN 2
  WHEN '3-5 purchases' THEN 3
  WHEN '6-10 purchases' THEN 4
  ELSE 5 END;
/* ~18k customer count for one-time buyers. 1743 and 114 for two purchases and 3-5 purchases, respectively */

-- 2. New customers vs. Returned customers
WITH customer_first_purchase AS (SELECT user_id, MIN(purchase_year * 100 + purchase_month) AS first_purchase_period
	FROM orders
	GROUP BY user_id)
SELECT o.purchase_year, o.purchase_month, COUNT(DISTINCT o.user_id) AS total_customers,
COUNT(DISTINCT CASE WHEN o.purchase_year * 100 + o.purchase_month = cfp.first_purchase_period 
		THEN o.user_id END) AS new_customers,
COUNT(DISTINCT CASE WHEN o.purchase_year * 100 + o.purchase_month != cfp.first_purchase_period 
		THEN o.user_id END) AS returning_customers,
ROUND(100.0 * COUNT(DISTINCT CASE WHEN o.purchase_year * 100 + o.purchase_month = cfp.first_purchase_period 
		THEN o.user_id END) / COUNT(DISTINCT o.user_id), 2) AS pct_new_customers
FROM orders o
JOIN customer_first_purchase cfp ON o.user_id = cfp.user_id
WHERE o.purchase_year > 0 AND o.purchase_month BETWEEN 1 AND 12
GROUP BY o.purchase_year, o.purchase_month
ORDER BY o.purchase_year, o.purchase_month;

-- 3. Revenue from new vs. returned
WITH customer_first_purchase AS (SELECT user_id, MIN(purchase_year * 100 + purchase_month) AS first_purchase_period
    FROM orders
    WHERE purchase_year != 0
    GROUP BY user_id)
SELECT o.purchase_year, 
	SUM(CASE WHEN o.purchase_year * 100 + o.purchase_month = cfp.first_purchase_period 
        THEN o.usd_price ELSE 0 END) AS new_customer_revenue,
    SUM(CASE WHEN o.purchase_year * 100 + o.purchase_month != cfp.first_purchase_period 
        THEN o.usd_price ELSE 0 END) AS returning_customer_revenue,
    ROUND(100.0 * SUM(CASE WHEN o.purchase_year * 100 + o.purchase_month = cfp.first_purchase_period 
        THEN o.usd_price ELSE 0 END) / SUM(o.usd_price), 2) AS pct_revenue_from_new
FROM orders o
JOIN customer_first_purchase cfp ON o.user_id = cfp.user_id
WHERE purchase_year != 0
GROUP BY o.purchase_year
ORDER BY o.purchase_year; -- Revenue still mainly comes from new customers, which is more than 95% in every year

-- IV. Product Performance
-- 1. Top selling products
SELECT product_name, COUNT(order_id) AS total_orders, SUM(usd_price) AS total_revenue, AVG(usd_price) AS avg_price,
ROUND(100.0 * SUM(usd_price) / SUM(SUM(usd_price)) OVER(), 2) AS pct_total_revenue
FROM orders
GROUP BY product_name
ORDER BY total_orders DESC; -- Nintendo Switch is the best-selling products, while Razer Pro Gaming Headset is the least with only 7 orders

-- 2. Average Revenue by Products
SELECT product_name, AVG(usd_price) AS avg_price
FROM orders
GROUP BY product_name
ORDER BY avg_price DESC; -- Sony Playstation 5 Bundle is highest, while JBL Quantum 100 Gaming Headset is lowest

-- 3. Product Performance by Region
SELECT o.product_name, r.region, COUNT(*) AS units_sold, SUM(o.usd_price) AS revenue, AVG(o.usd_price) AS avg_price,
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY o.product_name), 2) AS pct_of_product_volume
FROM orders o
LEFT JOIN region r ON o.country_code = r.country_code
GROUP BY o.product_name, r.region
ORDER BY o.product_name, units_sold DESC; -- NA always has the most orders and following is EMEA

-- V. (Marketing) Channel Analysis
-- 1. Revenue by Marketing Channel
SELECT marketing_channel, COUNT(*) AS total_orders, COUNT(DISTINCT user_id) AS unique_customers, SUM(usd_price) AS total_revenue, AVG(usd_price) AS avg_order_value,
    ROUND(SUM(usd_price) / COUNT(DISTINCT user_id), 2) AS revenue_per_customer
FROM orders
GROUP BY marketing_channel
ORDER BY total_revenue DESC;

-- 2. Revenue by Platform
SELECT purchase_platform, COUNT(*) AS total_orders, COUNT(DISTINCT user_id) AS customers, SUM(usd_price) AS total_revenue, AVG(usd_price) AS avg_price
FROM orders
GROUP BY purchase_platform
ORDER BY total_revenue DESC; -- Revenue through website is more than through mobile app nearly 10 times

-- 3. Platform vs. Channel interaction
SELECT purchase_platform, marketing_channel, COUNT(*) AS orders, SUM(usd_price) AS revenue, AVG(usd_price) AS avg_order_value, COUNT(DISTINCT user_id) AS customers,
ROUND(100.0 * SUM(usd_price) / SUM(SUM(usd_price)) OVER (PARTITION BY purchase_platform), 2) AS pct_within_platform
FROM orders
GROUP BY purchase_platform, marketing_channel
ORDER BY revenue DESC;
