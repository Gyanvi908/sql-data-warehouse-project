/*
================================================================================
Silver Layer - Data Quality Checks
================================================================================

Purpose:
    This script performs data quality and validation checks on the Bronze and
    Silver layer tables to ensure that the data is clean, standardized,
    consistent, and ready for downstream analytics.

Validation Areas:
    - Primary key nulls and duplicates
    - Unwanted spaces and hidden characters
    - Data standardization and consistency
    - Invalid and out-of-range dates
    - Negative or missing numeric values
    - Referential integrity between tables
    - Business rule validation
    - Consistency between related numerical fields

Expected Result:
    Most validation queries should return NO ROWS when the data quality rules
    are satisfied.

================================================================================
*/


/*
================================================================================
1. CRM CUSTOMER INFORMATION - BRONZE LAYER
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check for NULLs or duplicate customer IDs
-- Expectation: No results
-- Purpose:
--     The customer ID should be unique and should not contain NULL values.
-- ---------------------------------------------------------------------------

SELECT cst_id,
       COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- ---------------------------------------------------------------------------
-- Check for unwanted leading or trailing spaces
-- Expectation: No results
-- Purpose:
--     Customer first names should not contain unnecessary spaces.
-- ---------------------------------------------------------------------------

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- ---------------------------------------------------------------------------
-- Check gender value standardization
-- Expectation:
--     Values may contain variations such as F/M or Female/Male in Bronze.
-- Purpose:
--     Identify inconsistent gender values before standardization.
-- ---------------------------------------------------------------------------

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;


/*
================================================================================
2. CRM CUSTOMER INFORMATION - SILVER LAYER
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check for NULLs or duplicate customer IDs
-- Expectation: No results
-- Purpose:
--     Verify that the Silver transformation preserved customer ID uniqueness
--     and removed NULL primary key values.
-- ---------------------------------------------------------------------------

SELECT cst_id,
       COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- ---------------------------------------------------------------------------
-- Check for unwanted leading or trailing spaces
-- Expectation: No results
-- Purpose:
--     Verify that customer names were properly trimmed during transformation.
-- ---------------------------------------------------------------------------

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- ---------------------------------------------------------------------------
-- Check gender standardization
-- Expectation:
--     Standardized values should be Female, Male, or n/a.
-- ---------------------------------------------------------------------------

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


-- ---------------------------------------------------------------------------
-- Review Silver customer data
-- Purpose:
--     Perform a general inspection of the transformed customer records.
-- ---------------------------------------------------------------------------

SELECT *
FROM silver.crm_cust_info;


/*
================================================================================
3. CRM PRODUCT INFORMATION - BRONZE LAYER
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check for unwanted spaces in product names
-- Expectation: No results
-- Purpose:
--     Product names should not contain unnecessary leading or trailing spaces.
-- ---------------------------------------------------------------------------

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- ---------------------------------------------------------------------------
-- Check for NULL or negative product costs
-- Expectation: No results
-- Purpose:
--     Product cost should be a valid non-negative numeric value.
-- ---------------------------------------------------------------------------

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- ---------------------------------------------------------------------------
-- Check product line standardization
-- Expectation:
--     Identify all distinct product line values before standardization.
-- ---------------------------------------------------------------------------

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;


-- ---------------------------------------------------------------------------
-- Check for invalid product date ranges
-- Expectation: No results
-- Purpose:
--     Product end date should not occur before the product start date.
-- ---------------------------------------------------------------------------

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/*
================================================================================
4. CRM PRODUCT INFORMATION - SILVER LAYER
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check for NULLs or duplicate product IDs
-- Expectation: No results
-- Purpose:
--     Product ID should uniquely identify each product record.
-- ---------------------------------------------------------------------------

SELECT prd_id,
       COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- ---------------------------------------------------------------------------
-- Check product category referential integrity
-- Expectation: No results
-- Purpose:
--     Every product category derived from the product key should exist in
--     the ERP product category table.
-- ---------------------------------------------------------------------------

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN
(
    SELECT DISTINCT id
    FROM bronze.erp_px_cat_g1v2
);


/*
================================================================================
5. CRM SALES DETAILS
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check for invalid order dates
-- Expectation: No results
-- Purpose:
--     Validate that order dates are properly formatted and fall within the
--     expected business date range.
-- ---------------------------------------------------------------------------

SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;


-- ---------------------------------------------------------------------------
-- Check for invalid shipment dates
-- Expectation: No results
-- Purpose:
--     Validate that shipment dates are properly formatted and within the
--     expected date range.
-- ---------------------------------------------------------------------------

SELECT
    NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
   OR LEN(sls_ship_dt) != 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;


-- ---------------------------------------------------------------------------
-- Check for invalid due dates
-- Expectation: No results
-- Purpose:
--     Validate that due dates are properly formatted and within the expected
--     business date range.
-- ---------------------------------------------------------------------------

SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;


-- ---------------------------------------------------------------------------
-- Check chronological order of sales dates
-- Expectation: No results
-- Business Rule:
--     Order Date <= Ship Date
--     Order Date <= Due Date
-- ---------------------------------------------------------------------------

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- ---------------------------------------------------------------------------
-- Validate chronological order after Silver transformation
-- Expectation: No results
-- Purpose:
--     Confirm that date relationships remain valid after transformation.
-- ---------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- ---------------------------------------------------------------------------
-- Check consistency between Sales, Quantity, and Price
-- Expectation: No results after correction
-- Business Rule:
--     Sales = Quantity × Price
--
-- Additional rules:
--     - Sales should not be NULL or negative.
--     - Price should not be NULL or negative.
--     - Quantity should represent the number of units sold.
-- ---------------------------------------------------------------------------

SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,

    CASE
        WHEN sls_sales IS NULL
             OR sls_sales <= 0
             OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    CASE
        WHEN sls_price IS NULL
             OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;


/*
================================================================================
6. ERP CUSTOMER INFORMATION - AZ12
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check customer ID referential integrity
-- Expectation: No results
-- Purpose:
--     After removing the NAS prefix, each ERP customer ID should correspond
--     to a customer key in the Silver customer table.
-- ---------------------------------------------------------------------------

SELECT
    cid,
    CASE
        WHEN cid LIKE 'NAS%'
            THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cleaned_cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE
    CASE
        WHEN cid LIKE 'NAS%'
            THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END NOT IN
    (
        SELECT DISTINCT cst_key
        FROM silver.crm_cust_info
    );


-- ---------------------------------------------------------------------------
-- Check for out-of-range birth dates in Bronze
-- Expectation: No results
-- Purpose:
--     Identify unrealistic or invalid customer birth dates.
-- ---------------------------------------------------------------------------

SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- ---------------------------------------------------------------------------
-- Check for out-of-range birth dates in Silver
-- Expectation: No results
-- Purpose:
--     Verify that invalid future birth dates were handled during transformation.
-- ---------------------------------------------------------------------------

SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- ---------------------------------------------------------------------------
-- Review Silver ERP customer data
-- Purpose:
--     Perform a general inspection of transformed customer records.
-- ---------------------------------------------------------------------------

SELECT *
FROM silver.erp_cust_az12;


-- ---------------------------------------------------------------------------
-- Check gender standardization
-- Expectation:
--     Standardized values should be Female, Male, or n/a.
-- Purpose:
--     Compare the original gender values with the cleaned and normalized
--     representation.
-- ---------------------------------------------------------------------------

SELECT DISTINCT
    gen,

    TRIM(
        REPLACE(
            REPLACE(
                REPLACE(gen, CHAR(13), ''),
                CHAR(10), ''
            ),
            CHAR(9), ''
        )
    ) AS cleaned_gen,

    CASE
        WHEN UPPER(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(gen, CHAR(13), ''),
                        CHAR(10), ''
                    ),
                    CHAR(9), ''
                )
            )
        ) IN ('F', 'FEMALE')
        THEN 'Female'

        WHEN UPPER(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(gen, CHAR(13), ''),
                        CHAR(10), ''
                    ),
                    CHAR(9), ''
                )
            )
        ) IN ('M', 'MALE')
        THEN 'Male'

        ELSE 'n/a'
    END AS normalized_gen

FROM bronze.erp_cust_az12;


/*
================================================================================
7. ERP LOCATION INFORMATION - A101
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check customer ID referential integrity
-- Expectation: No results
-- Purpose:
--     Verify that location records correspond to valid customer keys.
-- ---------------------------------------------------------------------------

SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN
(
    SELECT cst_key
    FROM silver.crm_cust_info
);


-- ---------------------------------------------------------------------------
-- Check country standardization
-- Expectation:
--     Country codes should be transformed into consistent country names.
-- Purpose:
--     Review the original and standardized country values.
-- ---------------------------------------------------------------------------

SELECT DISTINCT
    cntry AS old_cntry,

    CASE
        WHEN TRIM(cntry) = 'DE'
            THEN 'Germany'

        WHEN TRIM(cntry) IN ('US', 'USA')
            THEN 'United States'

        WHEN TRIM(cntry) = ''
             OR cntry IS NULL
            THEN 'n/a'

        ELSE TRIM(cntry)
    END AS normalized_cntry

FROM bronze.erp_loc_a101
ORDER BY normalized_cntry;


-- ---------------------------------------------------------------------------
-- Check standardized country values in Silver
-- Expectation:
--     Values should be standardized and free from unnecessary spaces.
-- ---------------------------------------------------------------------------

SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ---------------------------------------------------------------------------
-- Review Silver ERP location data
-- ---------------------------------------------------------------------------

SELECT *
FROM silver.erp_loc_a101;


/*
================================================================================
8. ERP PRODUCT CATEGORY INFORMATION - G1V2
================================================================================
*/


-- ---------------------------------------------------------------------------
-- Check for unwanted spaces
-- Expectation: No results
-- Purpose:
--     Category, subcategory, and maintenance values should not contain
--     unnecessary leading or trailing spaces.
-- ---------------------------------------------------------------------------

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);


-- ---------------------------------------------------------------------------
-- Check maintenance value standardization
-- Expectation:
--     Standardized values should be Yes, No, or n/a.
-- Purpose:
--     Identify and normalize different representations of maintenance values.
-- ---------------------------------------------------------------------------

SELECT DISTINCT
    maintenance,

    TRIM(
        REPLACE(
            REPLACE(
                REPLACE(maintenance, CHAR(13), ''),
                CHAR(10), ''
            ),
            CHAR(9), ''
        )
    ) AS cleaned_maintenance,

    CASE
        WHEN UPPER(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(maintenance, CHAR(13), ''),
                        CHAR(10), ''
                    ),
                    CHAR(9), ''
                )
            )
        ) = 'YES'
        THEN 'Yes'

        WHEN UPPER(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(maintenance, CHAR(13), ''),
                        CHAR(10), ''
                    ),
                    CHAR(9), ''
                )
            )
        ) = 'NO'
        THEN 'No'

        ELSE 'n/a'
    END AS normalized_maintenance

FROM bronze.erp_px_cat_g1v2;


-- ---------------------------------------------------------------------------
-- Review Silver ERP product category data
-- ---------------------------------------------------------------------------

SELECT *
FROM silver.erp_px_cat_g1v2;
