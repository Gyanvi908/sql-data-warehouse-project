/*
================================================================================
Create Database and Schemas
================================================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking
    if it already exists.

    If the database exists, it is dropped and recreated. Additionally, the
    script creates three schemas within the database:
        - bronze
        - silver
        - gold

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it
    already exists.

    All data in the database will be permanently deleted.
    Proceed with caution and ensure you have proper backups before running
    this script.
================================================================================
*/


-- ============================================================
-- Create Database 'DataWarehouse'
-- ============================================================

USE master;


-- Drop the database if it already exists
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'DataWarehouse'
)
BEGIN
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouse;
END;


-- Create the database
CREATE DATABASE DataWarehouse;



-- ============================================================
-- Create Schemas
-- ============================================================

USE DataWarehouse;


CREATE SCHEMA bronze;


CREATE SCHEMA silver;


CREATE SCHEMA gold;
