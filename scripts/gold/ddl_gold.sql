/*
================================================================================
DDL Script: Gold Layer
================================================================================

Script Purpose:
    This script creates the Gold layer views for the SQL Data Warehouse.

    The Gold layer represents the final business-ready data model. It combines
    and integrates the cleaned Silver layer data into dimension and fact views
    that are optimized for analytics and reporting.

Objects Created:
    1. gold.dim_customers
       - Customer dimension
       - Combines CRM customer information with ERP customer and location data.

    2. gold.dim_products
       - Product dimension
       - Combines CRM product information with ERP product category information.
       - Keeps only the currently active product records.

    3. gold.fact_sales
       - Sales fact table
       - Combines sales transactions with customer and product dimensions.

Data Model:
    
                dim_customers
                      |
                      |
                 fact_sales
                      |
                      |
                dim_products

================================================================================
*/


/*
================================================================================
1. GOLD - CUSTOMER DIMENSION
================================================================================

Purpose:
    Creates the customer dimension by integrating customer information from:

        - silver.crm_cust_info
        - silver.erp_cust_az12
        - silver.erp_loc_a101

Business Rules:
    - CRM is treated as the master source for gender information.
    - ERP gender is used only when CRM gender is unavailable.
    - Customer location is obtained from the ERP location table.
    - A surrogate customer key is generated using ROW_NUMBER().

================================================================================
*/

CREATE VIEW gold.dim_customers AS

SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    ci.cst_id AS customer_id,

    ci.cst_key AS customer_number,

    ci.cst_firstname AS first_name,

    ci.cst_lastname AS last_name,

    la.cntry AS country,

    ci.cst_material_status AS marital_status,

    CASE
        WHEN ci.cst_gndr != 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    ca.bdate AS birthdate,

    ci.cst_create_date AS create_date

FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;

GO


/*
================================================================================
2. GOLD - PRODUCT DIMENSION
================================================================================

Purpose:
    Creates the product dimension by integrating product information from:

        - silver.crm_prd_info
        - silver.erp_px_cat_g1v2

Business Rules:
    - Product category information is obtained from the ERP category table.
    - Only currently active products are included.
    - Historical product records are filtered out using prd_end_dt IS NULL.
    - A surrogate product key is generated using ROW_NUMBER().

================================================================================
*/

CREATE VIEW gold.dim_products AS

SELECT
    ROW_NUMBER() OVER
    (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    pn.prd_id AS product_id,

    pn.prd_key AS product_number,

    pn.prd_nm AS product_name,

    pn.cat_id AS category_id,

    pc.cat AS category,

    pc.subcat AS subcategory,

    pc.maintenance,

    pn.prd_cost AS cost,

    pn.prd_line AS product_line,

    pn.prd_start_dt AS start_date

FROM silver.crm_prd_info AS pn

LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id

WHERE pn.prd_end_dt IS NULL;

GO


/*
================================================================================
3. GOLD - SALES FACT
================================================================================

Purpose:
    Creates the sales fact view by combining sales transactions from the Silver
    layer with the Gold customer and product dimensions.

Business Rules:
    - Each sales transaction is linked to a product dimension record.
    - Each sales transaction is linked to a customer dimension record.
    - Surrogate keys from the dimensions are used as foreign keys.
    - Sales measures such as sales amount, quantity, and price are retained.

Relationships:

    fact_sales
       |
       |-- customer_key --> dim_customers
       |
       |-- product_key  --> dim_products

================================================================================
*/

CREATE VIEW gold.fact_sales AS

SELECT
    sd.sls_ord_num AS order_number,

    pr.product_key,

    cu.customer_key,

    sd.sls_order_dt AS order_date,

    sd.sls_ship_dt AS shipping_date,

    sd.sls_due_dt AS due_date,

    sd.sls_sales AS sales_amount,

    sd.sls_quantity AS quantity,

    sd.sls_price AS price

FROM silver.crm_sales_details AS sd

LEFT JOIN gold.dim_products AS pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers AS cu
    ON sd.sls_cust_id = cu.customer_id;

GO
