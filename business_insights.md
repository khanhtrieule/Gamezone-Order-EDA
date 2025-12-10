# Gamezone Order Analysis - Business Insights Report

**Date:** November 10, 2025 - December 10, 2025  
**Analyzed by:** Khanh Le

---
## Summary
This EDA project analyzes the sales data of an online store about gaming-related projects from **2019-2021** to understand the business performance, customer behavior, and the contribution of marketing channels.

The analysis shows year-on-year revenue growth, high seasonality in the 4th quarter, low customer return rate, key products' revenue concentration, and clear differentiation between marketing channels and platforms.

The insights obtained help to propose optimal strategies and the EDA results provide an important foundation for further analysis

## Introduction
The dataset in the report contains multiple variables, including:
- **Order information** (order dates, order IDs, prices, quantities)
- **Customer details** (customers IDs, purchase frequency, new vs. returning status)
- **Product attributes** (product names, categories, price tiers)
- **Regional data** (country codes and mapped regions)
- **Marketing channels** 
- **Purchase platforms** (website vs. mobile app)

The purpose of this EDA project is to clean, explore, and gain insights into business trends that help clarify important questions, such as: **how revenue trends change over time, how much do new/return customers contribute, which products are the main drivers, and which marketing channels/platform are most effective**. 

These insights could support data-driven decisions related to marketing, inventory planning, and product optimization.

## I. Univariate Analysis
### **1. Price Statistics**  
Analysis of 21,719 orders reveals significant price variability
Total orders: **21,719**  
Minimum: **$0.00**   
Maximum: **$3,146.88**  
Average: **$281.02**  
Standard deviation: **$366.15** 

### **2. Price Distribution by Bin**  
- Most orders fall within the $150-200 (37.36%) range, followed by **$300-500** (19.67%) and **$0-50** (22.17%)
- High-priced orders (>$500) account for 8.22% of orders but contribute significantly to revenue (~$2.4M)
- Low-priced orders (<$50) make up 22% of orders but only contribute ~$120k to revenue -> Indicates the **high volume**, but **low revenue** impact

**3. Product Distribution**   
Top 3 products by order count:
- Nintendo Switch: 10,288 orders - $1.64M  
- 27in 4K Gaming Monitor: 4,686 orders  $1.95M
- JBL Quantum 100 Gaming Headset: 4,296 orders - $96k        

Top 3 products represent 88.7% of order volume and 60.6% of revenue   
There are a few items have **min_price = 0** (27in Monitor, JBL Headset, Dell Gaming Mouse) -> Checking data needed  

**4. Geographic Distribution**  
Orders are distributed mainly in **North America**, **EMEA**, **APAC**, and **LATAM**. The remain 0.19% is missing data   
Top countries by orders and revenue (Top 5): US (47.1% of orders), GB (8.26%), CA (4.36%)

**5. Marketing Channel Distribution**  
- **Direct**: 17,316 orders, average $298/order
- **Email**: 3,240 orders, average $187/order
- **Affliate & Social Media**: 714 & 320 orders, average $308/order and $215/order, respectively
- The volume of Direct and Email is high, Social Media contributes less revenue despite great engagement

**6. Platform Distribution**  
- **Website**: 19,642 orders, $5.95M, average $303/order
- **Mobile App**: 2,077 orders, $153k, average $73/order
- Website is the most preferred platform with ~90% orders, mobile app still shows potential growth despite less users

**7. Account Creation Method**  
 - **Desktop**: 16,331 orders, $4.73M
 - **Mobile**: 4,225 orders, $1.04M
 - **Tablet & TV**: Less impact with <1%
 - Desktop accounts most order count & revenue

 **8. Data Quality Issue Identified**   
 Issue requiring investigation before deeper and final analysis    
 1. **Zero dollar pricing:** 3 products show $0.00 minimum prices - 27in Monitor, JBL Headset, Dell Mouse
 2. **High Direct Attribution:** 79.73% direct traffic suggests possible mislabeled traffic sources 
 3. **Missing Region Data:** 42 orders with NULL region
 4. **Unknown Account Method:** 818 orders with unknown devices 

## II. Time Series Analysis
**1. Monthly Trends**  
**Insights:**
- Revenue and order count has a growth trend from **2019 to 2020**, indicates a significant increasing year over year
- Average monthly revenue was around $130k in 2019, while it exceeded **$350k** per month in 2020
- Strong seasonality: **December 2020** and **November-December 2019** having high revenue and order counts
- A steady rise shows in early 2020, likely due to high online shopping demand during quarantine months (March-May)
- **February 2019** was the weakest month - 320 orders and $80k revenue

**Recommendations:**

- Strengthen marketing and inventory in **Q4 (Oct-Dec)** to optimize demand spikes
- Consider launching campaigns in **mid year (Jun-Aug)** to balance seasonal fluctuations
- Use 2020 performance as a benchmark for post-pandemic growth expectations

**2. Average Performance by Month**   
**Insights:**
- Highest average monthly orders fall in **December - 1,235 orders** and **September - 1,088 orders** 
- Lowest average months are **February - 572 orders** and **January - 595 orders**
- Average order value stays consistent around **$260-280**, indicating stable pricing despite demand fluctuation
- Outperform consistently in both volume and revenue in holiday months **(Nov-Dec)**

**Recommendations:**

- Prepare marketing campaigns and stock in advance for **September-December**
- Promote offers in **January-February** to stimulate post-holiday sales

**3. Best and Worst Performing Months**   
**Insights:**
- **Best Month:** December 2020 - 1,671 orders, $549k revenue
- **Worst Month:** February 2019 - 320 orders, $80k revenue
- Revenue in December is almost 7 times higher than in February, indicates the strong seasonality

**Recommendations:** 
- Prepare in advance and promote holiday campaigns and maintain inventory readiness for December peaks 
- Prepare for **customer retention program** to maintain engagement after **Q4**

## III. Customer Analysis
**1. Customer Purchase Frequency Distribution**  
**Insights:**
- The vast majority are one-time buyers **(17,886 customers)**, contributing to **$4.92M**
- Only 1,743 are customers who made 2 purchases, contributing to **$1.07M**, which indicates strong revenue per repeat user
- High-value segment is small **(3-5 purchases)**, but generates **$102k**, meaning repeat buyers are extremely valuable

**Recommendations:** 
- Offer loyalty programs, membership tiers, or bundles to improve repeat purchase frquency
- Focus on remarketing for two-time buyers, as they have a high conversion potential

**2. New Vs. Returning Customers (Monthly)**
**Insights:**
- **97-100% customers are new customers** in most months, indicates high reliance on new customers than retention
- Returning customers are quite low with only **0-41 customers per month**, even when total customers exceed 1,000
- Customer churn is high, meaning customers buy once and do not return

**Recommendations:**
- Product recommendations, implement post-purchase email flows, and referral incentives to improve repeat purchase rate
- Analyze customer journey to identify problems causing low retention

**3. Revenue from New Vs. Returning Customers**  
**Insights:**
- Revenue is completely from **new customers**: 2019 - **97.83%**, 2020 - **96.63%**, 2021 - **95.22%**
- Although revenue from returning customers is quite low, but the trend is improving through years **(2.17% -> 3.37% -> 4.78%)**

**Recommendations:**
- Offer promotions for returning customers **(exclusive discounts, early access to new products)**
- Track customer lifetime value to identify high-value repeat users

## IV. Product Performance
**1. Top-selling Products**  
**Insights:**
Top 3 best-sellers:
- **27inch 4K Gaming Monitor** - $1.95M (32% total revenue)
- **Sony Playstation 5 Bundle** - $1.75M (25.8%)
- **Nintendo Switch** - $1.64M (26.9%)

- The average price of **Nintendo Switch** is low, but leads in units sold with **10,288** - High volume, moderate revenue   
- **PS5 Bundle** has a high average price and delivers nearly as much revenue as Nintendo Switch
- **Accessories (mouse, headphones)** have high units sold, but low revenue **(<2%)** - Low strategic impact

**Recommendations:**
- Maintain inventory and marketing for **top-selling products - Nintendo Switch, Playstation, monitors**
- For low-revenue products: Bundling them consoles/laptops to increase AOV

**2. Average Revenue by Product**  
**Insights:**
Clear price tiers: 
- **High-end**: PS5 Bundle, Lenovo Gaming 3, Acer Nitro
- **Mid-end**: 27inch 4K Gaming Monitor
- **Low-end**: JBL Headphones, Dell Mouse       
*PS5 Bundle has a highest revenue that 4 times Nintendo Switch, shows the impact of high-end product

**Recommendations:**
- Maintain **premium flagship position** for premium products
- Promote mid-end products for cross-sell **(4k Monitor)**

**3. Product Performance by Region**  
**Insights:**
- **NA** is always an impactful market with ~50-53% of total units sold for most products and highest revenue contribution across all SKUs 
- **EMEA** is the 2nd highest market with ~28-32%
- **APAC and LATAM** have lowest contribution with 5-15%

**Recommendations:**
- Promote more campaigns and strategies in NA and EMEA: Prioritize inventory allocation, Exclusive bundles, and Seasonal promotions
- Growth opportunity: Expanding distribution and logistics could improve share in APAC since they have high demand for laptops and accessories
- Regional pricing strategy: EMEA tends to pay slightly higher price - Keep positioning premium

## V. Marketing Channel Analysis
**1. Revenue by Marketing Channel**  
**Insights:**
- **Direct** is the highest channel with **17,316** orders and **$5.17M** revenue -> Most customers are from **organic traffic/brand recognition**
- **Email** is the second highest with **$604k** revenue, indicates the effective but **low AOV**
- **Affliate** has the most highest AOV & revenue per customer ($341/customer) even though the orders count is quite low -> Has a potential to growth, considering partnership
- **Social Media** is opposite with the lowest revenue, showcasing low conversion efficiency
- **Unknown** still has a quite high AOV -> Should check **tagging/tracking** to avoid data loss

**2. Revenue by Platform**  
**Insights:**
- **Website** accounts for almost all revenue with **$5.95M (97.5%)**
- **Mobile app** has an extremely low AOV (~$74), showcasing customers tend to use mobile app for lower-priced items or promotions
- Revenue from the mobile app is small, could possibly because **not optimizing the shopping experience** or **not having many in-app promotions**

**Recommendations:**
- Improve the UX and push notifications to improve conversion efficiency
- Promote exclusive discounts for mobile app to increase basket size

**3. Platform vs. Channel Interaction**  
**Insights:**
**Website**
- **Direct** -> 86% orders are from website -> Natural habit from customers
- **Email + Affliate** account ~12% -> 2 main marketing channels for website
- **Social Media and Unknown** account very little

**Mobile app**
- **Email accounts for 63% total app orders** -> The strongest channel on mobile 
- **Direct** is 28%, but the AOV is still low ($67)
- **Social Media** contributes 5.5%, more effective than on the website in proportion 
- **Affliate and Unknown** almost negligible on the app

**Recommendations:**
- Optimizing SEO, content, and organic reach for **Direct** because this is the main channel
- Increase content personalization and focus on upsell/cross-sell for **Email** to increase AOV
- Expanding network for **Affliate** and increase commission to attract new partnerships because this channel brings in the most quality customers
- Optimizing creative/remarketing for **Social Media** and run ads that lead to the website instead of an app to increase conversion
- Promoting in-app exclusive deals, improving UX/UI, and pushing notifications for **Mobile app**


