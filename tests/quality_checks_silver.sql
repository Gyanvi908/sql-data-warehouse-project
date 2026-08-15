-- quality checks silver 

--crm_cust_info
--Check for nulls or duplicates in primary key
-- expectation : No Result

SELECT cst_id,
count(*)
from bronze.crm_cust_info
group by cst_id 
having count(*) > 1 or cst_id is NULL



-- check for unwanted spaces
-- Expectation : No Results

select cst_firstname
from bronze.crm_cust_info 
where cst_firstname  != TRIM(cst_firstname )


-- Data Standardization & Consistency
Select distinct cst_gndr
from bronze.crm_cust_info 

--Check for nulls or duplicates in primary key
-- expectation : No Result

SELECT cst_id,
count(*)
from silver.crm_cust_info
group by cst_id 
having count(*) > 1 or cst_id is NULL



-- check for unwanted spaces
-- Expectation : No Results

select cst_firstname
from silver.crm_cust_info 
where cst_firstname  != TRIM(cst_firstname )


-- Data Standardization & Consistency
Select distinct cst_gndr
from silver.crm_cust_info 

SELECT * FROM silver.crm_cust_info


--Check for unwanted spaces 
--Expectation : No results
SELECT prd_nm
from bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for Nulls or Negative Numbers 
--Expectation : No results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL 


-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info


-- check for invalid date orders
SELECT * 
FROM bronze.crm_prd_info 
WHERE prd_end_dt < prd_start_dt 
--crm_prd_info

--clean and load crm_prd_info


SELECT prd_id,
count(*)
from silver.crm_prd_info
group by prd_id 
having count(*) > 1 or prd_id is NULL


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
(SELECT DISTINCT  id FROM  bronze.erp_px_cat_g1v2)


--crm_sales_details
--Check for Invalid Dates

SELECT 
NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
where sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT 
NULLIF(sls_ship_dt , 0) sls_ship_dt
FROM bronze.crm_sales_details
where sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

SELECT 
NULLIF(sls_due_dt , 0) sls_due_dt
FROM bronze.crm_sales_details
where sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check for Invalid Date Orders
SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt 

SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt 

-- Check Data Consistency : Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity, 
sls_price as old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
     ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price





--erp_cust_az12


-- Remove the unwanted column  
  
SELECT cid, 
  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
       ELSE cid
 END AS cid,
 bdate,
 gen
 FROM bronze.erp_cust_az12
 WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
       ELSE cid 
 END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)
 

 -- Identify Out-Of_range Dates
 
 SELECT DISTINCT 
 bdate
 FROM bronze.erp_cust_az12
 WHERE bdate < '1924-01-01' OR  bdate > GETDATE()
 
 SELECT DISTINCT 
 bdate
 FROM silver.erp_cust_az12
 WHERE bdate < '1924-01-01' OR  bdate > GETDATE()
 
 select * from silver.erp_cust_az12
 
 -- Data Standardization & Consistency

SELECT DISTINCT
    gen,

    -- Remove hidden characters
    TRIM(REPLACE(REPLACE(REPLACE(gen, CHAR(13), ''),CHAR(10), ''),CHAR(9), '')) AS cleaned_gen,
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


--erp_loc_a101

--silver 
SELECT 
REPLACE(cid, '-', '') cid,
 cntry
FROM bronze.erp_loc_a101 WHERE REPLACE(cid, '-', '') NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)

-- Data Standardization & Consistency
SELECT DISTINCT cntry AS old_cntry,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry 

SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry 

SELECT * FROM silver.erp_loc_a101 

--erp_px_cat_g1v2

-- Check for unwanted Spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency

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


select * from silver.erp_px_cat_g1v2
