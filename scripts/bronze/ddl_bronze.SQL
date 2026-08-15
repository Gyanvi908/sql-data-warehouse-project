/*
 * =============================================================================
 * DDL Script : Create Bronze Tables
 * =============================================================================
 *
 * Script Purpose:
 *   This script creates the Bronze layer tables.
 *   Existing Bronze tables are dropped before being recreated.
 *
 * =============================================================================
 */

-- =============================================================================
-- CRM: Customer Information
-- =============================================================================

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

    -- =========================================================
    -- Variables
    -- =========================================================

    DECLARE @start_time DATETIME2 = GETDATE();
    DECLARE @step_start_time DATETIME2;

    DECLARE @rows_inserted INT;
    DECLARE @total_rows INT;


    BEGIN TRY

        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';


        -- =========================================================
        -- CRM CUSTOMER INFO
        -- =========================================================

        SET @step_start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.crm_cust_info';

        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: Silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_create_date
        )

        SELECT
            cst_id,
            cst_key,

            TRIM(cst_firstname) AS cst_firstname,

            TRIM(cst_lastname) AS cst_lastname,

            CASE
                WHEN UPPER(TRIM(cst_material_status)) = 'S'
                    THEN 'Single'

                WHEN UPPER(TRIM(cst_material_status)) = 'M'
                    THEN 'Married'

                ELSE 'n/a'
            END AS cst_material_status,

            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F'
                    THEN 'Female'

                WHEN UPPER(TRIM(cst_gndr)) = 'M'
                    THEN 'Male'

                ELSE 'n/a'
            END AS cst_gndr,

            cst_create_date

        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last

            FROM bronze.crm_cust_info
        ) t

        WHERE flag_last = 1;


        SET @rows_inserted = @@ROWCOUNT;

        PRINT '>> crm_cust_info loaded successfully';

        PRINT '>> Rows Inserted: '
              + CAST(@rows_inserted AS VARCHAR);

        PRINT '>> Step Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @step_start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';


        -- =========================================================
        -- CRM PRODUCT INFO
        -- =========================================================

        SET @step_start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.crm_prd_info';

        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: Silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info
        (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )

        SELECT
            prd_id,

            REPLACE(
                SUBSTRING(prd_key, 1, 5),
                '-',
                '_'
            ) AS cat_id,

            SUBSTRING(
                prd_key,
                7,
                LEN(prd_key)
            ) AS prd_key,

            prd_nm,

            ISNULL(prd_cost, 0) AS prd_cost,

            CASE UPPER(TRIM(prd_line))

                WHEN 'M'
                    THEN 'Mountain'

                WHEN 'R'
                    THEN 'Road'

                WHEN 'S'
                    THEN 'Other Sales'

                WHEN 'T'
                    THEN 'Touring'

                ELSE 'n/a'

            END AS prd_line,

            CAST(
                prd_start_dt AS DATE
            ) AS prd_start_dt,

            CAST(
                LEAD(prd_start_dt) OVER
                (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
                AS DATETIME
            ) - 1 AS prd_end_dt

        FROM bronze.crm_prd_info;


        SET @rows_inserted = @@ROWCOUNT;

        PRINT '>> crm_prd_info loaded successfully';

        PRINT '>> Rows Inserted: '
              + CAST(@rows_inserted AS VARCHAR);

        PRINT '>> Step Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @step_start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';


        -- =========================================================
        -- CRM SALES DETAILS
        -- =========================================================

        SET @step_start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.crm_sales_details';

        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: Silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )

        SELECT

            sls_ord_num,

            sls_prd_key,

            sls_cust_id,


            -- Order Date
            CASE
                WHEN sls_order_dt = 0
                     OR LEN(sls_order_dt) != 8

                THEN NULL

                ELSE CAST(
                    CAST(
                        sls_order_dt AS VARCHAR(8)
                    )
                    AS DATE
                )

            END AS sls_order_dt,


            -- Ship Date
            CASE
                WHEN sls_ship_dt = 0
                     OR LEN(sls_ship_dt) != 8

                THEN NULL

                ELSE CAST(
                    CAST(
                        sls_ship_dt AS VARCHAR(8)
                    )
                    AS DATE
                )

            END AS sls_ship_dt,


            -- Due Date
            CASE
                WHEN sls_due_dt = 0
                     OR LEN(sls_due_dt) != 8

                THEN NULL

                ELSE CAST(
                    CAST(
                        sls_due_dt AS VARCHAR(8)
                    )
                    AS DATE
                )

            END AS sls_due_dt,


            -- Sales
            CASE

                WHEN sls_sales IS NULL
                     OR sls_sales <= 0
                     OR sls_sales != sls_quantity * ABS(sls_price)

                THEN sls_quantity * ABS(sls_price)

                ELSE sls_sales

            END AS sls_sales,


            sls_quantity,


            -- Price
            CASE

                WHEN sls_price IS NULL
                     OR sls_price <= 0

                THEN sls_sales /
                     NULLIF(sls_quantity, 0)

                ELSE sls_price

            END AS sls_price


        FROM bronze.crm_sales_details;


        SET @rows_inserted = @@ROWCOUNT;

        PRINT '>> crm_sales_details loaded successfully';

        PRINT '>> Rows Inserted: '
              + CAST(@rows_inserted AS VARCHAR);

        PRINT '>> Step Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @step_start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';


        -- =========================================================
        -- ERP CUSTOMER AZ12
        -- =========================================================

        SET @step_start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.erp_cust_az12';

        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: Silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )

        SELECT


            -- Customer ID
            CASE

                WHEN cid LIKE 'NAS%'

                THEN SUBSTRING(
                    cid,
                    4,
                    LEN(cid)
                )

                ELSE cid

            END AS cid,


            -- Birth Date
            CASE

                WHEN bdate > GETDATE()

                THEN NULL

                ELSE bdate

            END AS bdate,


            -- Gender
            CASE

                WHEN UPPER(
                    TRIM(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    gen,
                                    CHAR(13),
                                    ''
                                ),
                                CHAR(10),
                                ''
                            ),
                            CHAR(9),
                            ''
                        )
                    )
                ) IN ('F', 'FEMALE')

                THEN 'Female'


                WHEN UPPER(
                    TRIM(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    gen,
                                    CHAR(13),
                                    ''
                                ),
                                CHAR(10),
                                ''
                            ),
                            CHAR(9),
                            ''
                        )
                    )
                ) IN ('M', 'MALE')

                THEN 'Male'


                ELSE 'n/a'

            END AS gen


        FROM bronze.erp_cust_az12;


        SET @rows_inserted = @@ROWCOUNT;

        PRINT '>> erp_cust_az12 loaded successfully';

        PRINT '>> Rows Inserted: '
              + CAST(@rows_inserted AS VARCHAR);

        PRINT '>> Step Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @step_start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';


        -- =========================================================
        -- ERP LOCATION A101
        -- =========================================================

        SET @step_start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.erp_loc_a101';

        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: Silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )

        SELECT

            REPLACE(
                cid,
                '-',
                ''
            ) AS cid,


            CASE

                WHEN TRIM(cntry) = 'DE'

                THEN 'Germany'


                WHEN TRIM(cntry) IN ('US', 'USA')

                THEN 'United States'


                WHEN TRIM(cntry) = ''
                     OR cntry IS NULL

                THEN 'n/a'


                ELSE TRIM(cntry)

            END AS cntry


        FROM bronze.erp_loc_a101;


        SET @rows_inserted = @@ROWCOUNT;

        PRINT '>> erp_loc_a101 loaded successfully';

        PRINT '>> Rows Inserted: '
              + CAST(@rows_inserted AS VARCHAR);

        PRINT '>> Step Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @step_start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';


        -- =========================================================
        -- ERP PRODUCT CATEGORY
        -- =========================================================

        SET @step_start_time = GETDATE();

        PRINT '>> Truncating Table: Silver.erp_px_cat_g1v2';

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: Silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2
        (
            id,
            cat,
            subcat,
            maintenance
        )

        SELECT

            TRIM(id) AS id,

            TRIM(cat) AS cat,

            TRIM(subcat) AS subcat,


            -- Maintenance
            CASE

                WHEN UPPER(
                    TRIM(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    maintenance,
                                    CHAR(13),
                                    ''
                                ),
                                CHAR(10),
                                ''
                            ),
                            CHAR(9),
                            ''
                        )
                    )
                ) = 'YES'

                THEN 'Yes'


                WHEN UPPER(
                    TRIM(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    maintenance,
                                    CHAR(13),
                                    ''
                                ),
                                CHAR(10),
                                ''
                            ),
                            CHAR(9),
                            ''
                        )
                    )
                ) = 'NO'

                THEN 'No'


                ELSE 'n/a'

            END AS maintenance


        FROM bronze.erp_px_cat_g1v2;


        SET @rows_inserted = @@ROWCOUNT;

        PRINT '>> erp_px_cat_g1v2 loaded successfully';

        PRINT '>> Rows Inserted: '
              + CAST(@rows_inserted AS VARCHAR);

        PRINT '>> Step Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @step_start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';


        -- =========================================================
        -- TOTAL ROWS
        -- =========================================================

        /*
            Calculate total rows separately.

            Do NOT put these SELECT statements directly
            inside PRINT. That was causing SQL Error 1046.
        */

        SELECT @total_rows =

              (SELECT COUNT(*)
               FROM silver.crm_cust_info)

            + (SELECT COUNT(*)
               FROM silver.crm_prd_info)

            + (SELECT COUNT(*)
               FROM silver.crm_sales_details)

            + (SELECT COUNT(*)
               FROM silver.erp_cust_az12)

            + (SELECT COUNT(*)
               FROM silver.erp_loc_a101)

            + (SELECT COUNT(*)
               FROM silver.erp_px_cat_g1v2);


        -- =========================================================
        -- FINAL SUCCESS MESSAGE
        -- =========================================================

        PRINT '================================================';

        PRINT 'Silver Layer Loaded Successfully';

        PRINT '>> Total Rows Loaded: '
              + CAST(
                    @total_rows
                    AS VARCHAR
                );

        PRINT '>> Total Silver Loading Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';

        PRINT '================================================';


    END TRY


    -- =========================================================
    -- ERROR HANDLING
    -- =========================================================

    BEGIN CATCH

        PRINT '================================================';

        PRINT 'ERROR OCCURRED WHILE LOADING SILVER LAYER';


        PRINT 'Error Number: '
              + CAST(
                    ERROR_NUMBER()
                    AS VARCHAR
                );


        PRINT 'Error Message: '
              + ERROR_MESSAGE();


        PRINT 'Error Line: '
              + CAST(
                    ERROR_LINE()
                    AS VARCHAR
                );


        PRINT 'Total Duration Before Error: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        GETDATE()
                    )
                    AS VARCHAR
                )
              + ' ms';


        PRINT '================================================';


        -- Re-throw the original error
        THROW;

    END CATCH

END;
