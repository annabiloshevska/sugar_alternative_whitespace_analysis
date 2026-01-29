/*
================================================================================
SUGAR ALTERNATIVE WHITESPACE ANALYSIS
===============================================================================

-- ============================================================================
-- SECTION 1: TABLE CREATION
-- ============================================================================

DROP TABLE IF EXISTS category_trends CASCADE;
DROP TABLE IF EXISTS sweetener_trends CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- Table 1: Categories 
CREATE TABLE categories (
    category VARCHAR(255) PRIMARY KEY,
    avg_sugar DECIMAL(10, 6),
    sugar_load DECIMAL(10, 6),
    market_gap DECIMAL(10, 6),
    market_size INTEGER,
    sugar_load_norm DECIMAL(10, 6),
    gap_norm DECIMAL(10, 6),
    size_norm DECIMAL(10, 6),
    opportunity_score DECIMAL(10, 6),
    avg_interest DECIMAL(10, 6),
    growth_rate DECIMAL(10, 6),
    social_velocity DECIMAL(10, 6),
    social_velocity_norm DECIMAL(10, 6),
    final_opportunity_score DECIMAL(10, 6),
    priority VARCHAR(50)
);

-- Table 2: USDA Products 
CREATE TABLE products (
    fdc_id INTEGER PRIMARY KEY,
    description TEXT,
    branded_food_category VARCHAR(255),
    ingredients TEXT,
    sugar_100g DECIMAL(10, 2),
    sugar_bin VARCHAR(50),
    has_sugar_alternative BOOLEAN
);

-- Table 3: Trends
CREATE TABLE category_trends (
    category VARCHAR(255),
    avg_interest DECIMAL(10, 2),
    growth_rate DECIMAL(10, 2)
);
-- Table 4: Sweetner Trends
CREATE TABLE sweetener_trends (
    sweetener VARCHAR(255),
    avg_interest DECIMAL,
    growth_rate DECIMAL
);

-- ============================================================================
-- SECTION 2: DATA LOADING
-- ============================================================================
-- 1. Load Categories
COPY categories FROM 'C:/Users/Public/processed/final_opportunity_analysis.csv' 
DELIMITER ',' CSV HEADER;

-- 2. Load Products
COPY products FROM 'C:/Users/Public/processed/us_products_processed.csv' 
DELIMITER ',' CSV HEADER;

-- 3. Load Trends
COPY category_trends FROM 'C:/Users/Public/processed/category_trends.csv' 
DELIMITER ',' CSV HEADER;

--4. Load Sweetners Trends
COPY sweetener_trends FROM 'C:/Users/Public/processed/sweetener_trends.csv'
DELIMITER ',' CSV HEADER;

-- ============================================================================
-- SECTION 3: DATA FIXES AND QUALITY CHECKS
-- ============================================================================
-- Standardize whitespace and casing
UPDATE categories SET category = TRIM(category);
UPDATE products SET branded_food_category = TRIM(branded_food_category);

-- Fix specific naming mismatches for the 5 problematic categories
UPDATE products SET branded_food_category = 'Biscuitscookies Shelf Stable' WHERE branded_food_category ILIKE '%Biscuit%' AND branded_food_category ILIKE '%Cookie%';
UPDATE products SET branded_food_category = 'Yogurtyogurt Substitutes' WHERE branded_food_category ILIKE '%Yogurt%' AND branded_food_category ILIKE '%Substitute%';
UPDATE products SET branded_food_category = 'Processed Cereal Products' WHERE branded_food_category ILIKE '%Cereal%' AND branded_food_category ILIKE '%Processed%';
UPDATE products SET branded_food_category = 'Lunch Snacks Combinations' WHERE branded_food_category ILIKE '%Lunch%' AND branded_food_category ILIKE '%Snack%';
UPDATE products SET branded_food_category = 'Frozen Bread Dough' WHERE branded_food_category ILIKE '%Bread%' AND branded_food_category ILIKE '%Dough%';

-- Final character cleaning
UPDATE categories SET category = REGEXP_REPLACE(category, '[^a-zA-Z0-9 ]', '', 'g');
UPDATE products SET branded_food_category = REGEXP_REPLACE(branded_food_category, '[^a-zA-Z0-9 ]', '', 'g');
UPDATE categories SET category = INITCAP(TRIM(category));
UPDATE products SET branded_food_category = INITCAP(TRIM(branded_food_category));

SELECT c.category 
FROM categories c
LEFT JOIN products p ON c.category = p.branded_food_category
WHERE p.branded_food_category IS NULL;

SELECT 
    (SELECT COUNT(*) FROM categories) as cat_count,
    (SELECT COUNT(*) FROM products) as prod_count,
    (SELECT COUNT(*) FROM sweetener_trends) as sweet_count;
-- ============================================================================
-- SECTION 4: ANALYTICAL QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1: Top 3 High-Opportunity Categories with Key Metrics
-- ----------------------------------------------------------------------------
-- Business Question: Which categories should we prioritize for investment?

SELECT 
    c.category,
    c.priority,
    ROUND(c.final_opportunity_score, 2) AS opportunity_score,
    ROUND(c.avg_sugar, 2) AS avg_sugar_per_100g,
    ROUND(c.market_gap, 2) AS pct_without_alternatives,
    c.market_size AS total_products,
    ROUND(c.avg_interest, 1) AS google_interest,
    ROUND(c.growth_rate, 1) AS trend_growth_rate,
    COUNT(p.fdc_id) AS products_in_db
FROM categories c
LEFT JOIN products p ON c.category = p.branded_food_category
WHERE c.priority = 'HIGH'
GROUP BY c.category, c.priority, c.final_opportunity_score, c.avg_sugar, 
         c.market_gap, c.market_size, c.avg_interest, c.growth_rate
ORDER BY c.final_opportunity_score DESC
LIMIT 3;

-- ----------------------------------------------------------------------------
-- QUERY 2: Sugar Alternative Penetration Analysis
-- ----------------------------------------------------------------------------
-- Business Question: How well-penetrated is each category with alternatives?

SELECT 
    branded_food_category AS category,
    COUNT(*) AS total_products,
    SUM(CASE WHEN has_sugar_alternative = TRUE THEN 1 ELSE 0 END) AS products_with_alternatives,
    SUM(CASE WHEN has_sugar_alternative = FALSE THEN 1 ELSE 0 END) AS products_without_alternatives,
    ROUND(100.0 * SUM(CASE WHEN has_sugar_alternative = TRUE THEN 1 ELSE 0 END) / COUNT(*), 2) 
        AS pct_with_alternatives,
    ROUND(100.0 * SUM(CASE WHEN has_sugar_alternative = FALSE THEN 1 ELSE 0 END) / COUNT(*), 2) 
        AS pct_without_alternatives,
    ROUND(AVG(sugar_100g), 2) AS avg_sugar_content
FROM products
WHERE branded_food_category IS NOT NULL
GROUP BY branded_food_category
HAVING COUNT(*) >= 20  -- Statistically meaningful categories
ORDER BY pct_without_alternatives DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- QUERY 3: Ingredient Analysis - Finding Sugar Alternative Patterns
-- ----------------------------------------------------------------------------
-- Business Question: What sweeteners are commonly used in alternatives?

SELECT 
    branded_food_category,
    COUNT(*) AS products_with_alternatives,
    SUM(CASE WHEN LOWER(ingredients) LIKE '%stevia%' THEN 1 ELSE 0 END) AS uses_stevia,
    SUM(CASE WHEN LOWER(ingredients) LIKE '%erythritol%' THEN 1 ELSE 0 END) AS uses_erythritol,
    SUM(CASE WHEN LOWER(ingredients) LIKE '%monk fruit%' THEN 1 ELSE 0 END) AS uses_monk_fruit,
    SUM(CASE WHEN LOWER(ingredients) LIKE '%allulose%' THEN 1 ELSE 0 END) AS uses_allulose,
    SUM(CASE WHEN LOWER(ingredients) LIKE '%sucralose%' THEN 1 ELSE 0 END) AS uses_sucralose,
    ROUND(100.0 * SUM(CASE WHEN LOWER(ingredients) LIKE '%stevia%' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        AS pct_stevia
FROM products
WHERE has_sugar_alternative = TRUE
  AND ingredients IS NOT NULL
  AND branded_food_category IS NOT NULL
GROUP BY branded_food_category
HAVING COUNT(*) >= 5
ORDER BY products_with_alternatives DESC
LIMIT 15;

-- ----------------------------------------------------------------------------
-- QUERY 4: Product-Level Opportunity Identification
-- ----------------------------------------------------------------------------
-- Business Question: Which specific high-sugar products lack alternatives?

WITH ranked_products AS (
    SELECT 
        p.fdc_id,
        p.description,
        p.branded_food_category,
        p.sugar_100g,
        p.has_sugar_alternative,
        c.final_opportunity_score AS category_score,
        c.priority,
        RANK() OVER (PARTITION BY p.branded_food_category 
                     ORDER BY p.sugar_100g DESC) AS sugar_rank_in_category
    FROM products p
    INNER JOIN categories c ON p.branded_food_category = c.category
    WHERE p.sugar_100g IS NOT NULL
      AND p.has_sugar_alternative = FALSE
      AND c.priority IN ('HIGH', 'MEDIUM')
)
SELECT 
    fdc_id,
    description,
    branded_food_category,
    ROUND(sugar_100g, 2) AS sugar_per_100g,
    ROUND(category_score, 2) AS category_opportunity_score,
    priority,
    sugar_rank_in_category
FROM ranked_products
WHERE sugar_rank_in_category <= 5  -- Top 5 highest sugar products per category
ORDER BY category_score DESC, sugar_rank_in_category
LIMIT 50;

----------------------------------------------------
-- QUERY 5: Executive Dashboard Summary - Top 5 Recommendations
-- ----------------------------------------------------------------------------
-- Business Question: What are our top 3-5 investment recommendations?

WITH top_opportunities AS (
    SELECT 
        c.category,
        c.final_opportunity_score,
        c.market_size,
        c.market_gap,
        c.avg_sugar,
        c.growth_rate,
        c.avg_interest,
        COUNT(p.fdc_id) AS products_analyzed,
        SUM(CASE WHEN p.has_sugar_alternative = FALSE THEN 1 ELSE 0 END) AS untapped_products
    FROM categories c
    LEFT JOIN products p ON c.category = p.branded_food_category
    WHERE c.priority = 'HIGH'
    GROUP BY c.category, c.final_opportunity_score, c.market_size, c.market_gap, 
             c.avg_sugar, c.growth_rate, c.avg_interest
    ORDER BY c.final_opportunity_score DESC
    LIMIT 5
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY final_opportunity_score DESC) AS recommendation_rank,
    category,
    ROUND(final_opportunity_score, 1) AS opportunity_score,
    market_size AS total_market_products,
    untapped_products AS products_without_alternatives,
    ROUND(market_gap, 1) AS market_gap_pct,
    ROUND(avg_sugar, 1) AS avg_sugar_per_100g,
    ROUND(avg_interest, 1) AS consumer_interest_index,
    ROUND(growth_rate, 1) AS yoy_growth_pct,
    -- Investment Rationale
    CASE 
        WHEN final_opportunity_score >= 90 THEN 'Immediate Investment - Exceptional Opportunity'
        WHEN final_opportunity_score >= 80 THEN 'High Priority - Strong Multi-KPI Performance'
        WHEN final_opportunity_score >= 70 THEN 'Recommended - Solid Fundamentals'
        ELSE 'Consider - Monitor Trends'
    END AS recommendation,
    -- Key Success Factors
    CONCAT(
        'High sugar content (', ROUND(avg_sugar, 0), 'g/100g), ',
        ROUND(market_gap, 0), '% market gap, ',
        market_size, ' product market, ',
        CASE WHEN growth_rate > 5 THEN 'growing trend' ELSE 'stable trend' END
    ) AS key_factors
FROM top_opportunities
ORDER BY recommendation_rank;
