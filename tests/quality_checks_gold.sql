/*
================================================================================
Quality Checks: Gold Layer
================================================================================

Script Purpose:
    This script performs data quality and integrity checks on the Gold layer.

    The Gold layer contains business-ready dimension and fact views created
    from the cleaned and standardized Silver layer.

Objects Validated:
    1. gold.dim_customers
    2. gold.dim_products
    3. gold.fact_sales

Validation Areas:
    - NULL values
    - Duplicate surrogate keys
    - Dimension uniqueness
    - Foreign key integrity
    - Data integration between dimensions
    - Business-rule consistency
    - Referential integrity between fact and dimension views

Expected Result:
    Validation queries should return NO RESULTS when the Gold layer
    satisfies the expected data quality rules.

================================================================================
*/


/*
================================================================================
1. GOLD CUSTOMER DIMENSION
================================================================================
*/


-- -----------------------------------------------------------------------------
-- Check for NULL or duplicate customer surrogate keys
-- Expectation: No results
-- Purpose:
--     customer_key should uniquely identify every customer in the dimension.
-- -----------------------------------------------------------------------------

SELECT
    customer_key,
    COUNT(*) AS record_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1
    OR customer_key IS NULL;


-- -----------------------------------------------------------------------------
-- Check for NULL or duplicate customer IDs
-- Expectation: No results
-- Purpose:
--     customer_id should uniquely identify customers in the Gold dimension.
-- -----------------------------------------------------------------------------

SELECT
    customer_id,
    COUNT(*) AS record_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1
    OR customer_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for NULL customer numbers
-- Expectation: No results
-- Purpose:
--     Customer numbers are required to link customer information across
--     different source systems.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_customers
WHERE customer_number IS NULL;


-- -----------------------------------------------------------------------------
-- Check gender standardization
-- Expectation:
--     Only Female, Male, or n/a should be present.
-- Purpose:
--     Verify that gender information was correctly integrated from CRM and ERP.
-- -----------------------------------------------------------------------------

SELECT DISTINCT gender
FROM gold.dim_customers;


-- -----------------------------------------------------------------------------
-- Check customer gender integration between CRM and ERP
-- Expectation:
--     CRM gender should be used when available.
--     ERP gender should be used only when CRM gender is unavailable.
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    ci.cst_gndr AS crm_gender,
    ca.gen AS erp_gender,

    CASE
        WHEN ci.cst_gndr != 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS final_gender

FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

ORDER BY crm_gender, erp_gender;


-- -----------------------------------------------------------------------------
-- Review Gold customer dimension
-- Purpose:
--     General inspection of the final customer dimension.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_customers;


/*
================================================================================
2. GOLD PRODUCT DIMENSION
================================================================================
*/


-- -----------------------------------------------------------------------------
-- Check for NULL or duplicate product surrogate keys
-- Expectation: No results
-- Purpose:
--     product_key should uniquely identify each product.
-- -----------------------------------------------------------------------------

SELECT
    product_key,
    COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1
    OR product_key IS NULL;


-- -----------------------------------------------------------------------------
-- Check for NULL or duplicate product IDs
-- Expectation: No results
-- Purpose:
--     Each product should have a unique product ID.
-- -----------------------------------------------------------------------------

SELECT
    product_id,
    COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1
    OR product_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for NULL product numbers
-- Expectation: No results
-- Purpose:
--     Product numbers are used to link sales transactions to products.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products
WHERE product_number IS NULL;


-- -----------------------------------------------------------------------------
-- Check that only active products are present
-- Expectation: No results
-- Purpose:
--     Gold product dimension should contain only the currently active
--     product records.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products dp
INNER JOIN silver.crm_prd_info sp
    ON dp.product_number = sp.prd_key
WHERE sp.prd_end_dt IS NOT NULL;


-- -----------------------------------------------------------------------------
-- Check product category integrity
-- Expectation: No results
-- Purpose:
--     Every product category should have a corresponding record in the
--     ERP product category information.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products
WHERE category_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check product dimension for NULL business attributes
-- Expectation:
--     Critical attributes such as product name and product number should
--     not be NULL.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products
WHERE product_number IS NULL
   OR product_name IS NULL;


-- -----------------------------------------------------------------------------
-- Review Gold product dimension
-- Purpose:
--     General inspection of the final product dimension.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products;


/*
================================================================================
3. GOLD SALES FACT
================================================================================
*/


-- -----------------------------------------------------------------------------
-- Check for NULL product foreign keys
-- Expectation: No results
-- Purpose:
--     Every sales transaction should be associated with a valid product
--     dimension record.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL;


-- -----------------------------------------------------------------------------
-- Check for NULL customer foreign keys
-- Expectation: No results
-- Purpose:
--     Every sales transaction should be associated with a valid customer
--     dimension record.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL;


-- -----------------------------------------------------------------------------
-- Check sales fact for NULL order numbers
-- Expectation: No results
-- Purpose:
--     Every sales transaction should have a valid order number.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE order_number IS NULL;


-- -----------------------------------------------------------------------------
-- Check sales measures
-- Expectation: No results
-- Purpose:
--     Sales amount, quantity, and price should contain valid values.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE sales_amount IS NULL
   OR sales_amount < 0
   OR quantity IS NULL
   OR quantity < 0
   OR price IS NULL
   OR price < 0;


-- -----------------------------------------------------------------------------
-- Check sales amount consistency
-- Expectation: No results
-- Business Rule:
--     Sales Amount = Quantity × Price
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE sales_amount != quantity * price;


-- -----------------------------------------------------------------------------
-- Check chronological order of sales dates
-- Expectation: No results
-- Business Rule:
--     Order Date <= Shipping Date
--     Order Date <= Due Date
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE order_date > shipping_date
   OR order_date > due_date;


/*
================================================================================
4. GOLD FACT-DIMENSION FOREIGN KEY INTEGRITY
================================================================================

Purpose:
    Verify that every foreign key in the sales fact view corresponds to a
    valid record in its respective dimension.

================================================================================
*/


-- -----------------------------------------------------------------------------
-- Check customer foreign key integrity
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    f.customer_key
FROM gold.fact_sales AS f

LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key

WHERE c.customer_key IS NULL;


-- -----------------------------------------------------------------------------
-- Check product foreign key integrity
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    f.product_key
FROM gold.fact_sales AS f

LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key

WHERE p.product_key IS NULL;


-- -----------------------------------------------------------------------------
-- Combined foreign key integrity check
-- Expectation: No results
-- Purpose:
--     Validate both customer and product relationships in the sales fact.
-- -----------------------------------------------------------------------------

SELECT
    f.*
FROM gold.fact_sales AS f

LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key

LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key

WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;


/*
================================================================================
5. GOLD LAYER SUMMARY CHECKS
================================================================================

Purpose:
    Provide a quick overview of the number of records available in each
    Gold object.

================================================================================
*/

SELECT
    'dim_customers' AS object_name,
    COUNT(*) AS record_count
FROM gold.dim_customers

UNION ALL

SELECT
    'dim_products' AS object_name,
    COUNT(*) AS record_count
FROM gold.dim_products

UNION ALL

SELECT
    'fact_sales' AS object_name,
    COUNT(*) AS record_count
FROM gold.fact_sales;
