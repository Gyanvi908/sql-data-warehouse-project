/*
================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
================================================================================

Script Purpose:
    This stored procedure loads data into the Bronze schema from CSV files.

    It performs the following actions:
    - Truncates existing Bronze tables.
    - Loads data from CSV files using BULK INSERT.
    - Prints loading progress and row counts.
    - Handles errors using TRY/CATCH.

Usage:
    EXEC bronze.load_bronze;
================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    -- =========================================================
    -- Variables
    -- =========================================================

    DECLARE @start_time DATETIME2;
    DECLARE @end_time DATETIME2;
    DECLARE @batch_start_time DATETIME2;
    DECLARE @batch_end_time DATETIME2;
    DECLARE @rows_inserted INT;


    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';


        -- =========================================================
        -- CRM TABLES
        -- =========================================================

        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';


        -- =========================================================
        -- CRM: Customer Information
        -- =========================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_cust_info';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/datasets/source_crm/cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- IMPORTANT:
        -- Capture @@ROWCOUNT immediately after BULK INSERT
        SET @rows_inserted = @@ROWCOUNT;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        @end_time
                    )
                    AS VARCHAR
                )
              + ' ms';

        PRINT '('
              + CAST(@rows_inserted AS VARCHAR)
              + ' rows affected)';


        -- =========================================================
        -- CRM: Product Information
        -- =========================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_prd_info';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/datasets/source_crm/prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        @end_time
                    )
                    AS VARCHAR
                )
              + ' ms';

        PRINT '('
              + CAST(@rows_inserted AS VARCHAR)
              + ' rows affected)';


        -- =========================================================
        -- CRM: Sales Details
        -- =========================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/datasets/source_crm/sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        @end_time
                    )
                    AS VARCHAR
                )
              + ' ms';

        PRINT '('
              + CAST(@rows_inserted AS VARCHAR)
              + ' rows affected)';


        -- =========================================================
        -- ERP TABLES
        -- =========================================================

        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';


        -- =========================================================
        -- ERP: Customer Information
        -- =========================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/datasets/source_erp/CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        @end_time
                    )
                    AS VARCHAR
                )
              + ' ms';

        PRINT '('
              + CAST(@rows_inserted AS VARCHAR)
              + ' rows affected)';


        -- =========================================================
        -- ERP: Location Information
        -- =========================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/datasets/source_erp/LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        @end_time
                    )
                    AS VARCHAR
                )
              + ' ms';

        PRINT '('
              + CAST(@rows_inserted AS VARCHAR)
              + ' rows affected)';


        -- =========================================================
        -- ERP: Product Category Information
        -- =========================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @start_time,
                        @end_time
                    )
                    AS VARCHAR
                )
              + ' ms';

        PRINT '('
              + CAST(@rows_inserted AS VARCHAR)
              + ' rows affected)';


        -- =========================================================
        -- Completion
        -- =========================================================

        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT 'Bronze Layer Loading Completed Successfully';

        PRINT '>> Total Bronze Loading Duration: '
              + CAST(
                    DATEDIFF(
                        MILLISECOND,
                        @batch_start_time,
                        @batch_end_time
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
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';

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

        PRINT '================================================';

        THROW;

    END CATCH

END;
