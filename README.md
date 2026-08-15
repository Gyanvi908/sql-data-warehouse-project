# 🏗️ SQL Data Warehouse & Analytics Engineering Project

<p align="center">
  <img src="docs/data_architecture.png" alt="SQL Data Warehouse Architecture" width="100%">
</p>

<h3 align="center">
From Raw CRM & ERP Data → Clean Data → Integrated Data → Business-Ready Analytics
</h3>

<p align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-Data%20Warehouse-red?style=for-the-badge&logo=microsoftsqlserver)

![T-SQL](https://img.shields.io/badge/T--SQL-ETL-blue?style=for-the-badge)

![Medallion Architecture](https://img.shields.io/badge/Architecture-Medallion-orange?style=for-the-badge)

![Star Schema](https://img.shields.io/badge/Model-Star%20Schema-yellow?style=for-the-badge)

![Data Engineering](https://img.shields.io/badge/Domain-Data%20Engineering-success?style=for-the-badge)

</p>

---

# 📌 Project Overview

This project implements an **end-to-end SQL Server Data Warehouse** that transforms raw operational data from **CRM and ERP source systems** into a clean, standardized, integrated, and business-ready analytical model.

The warehouse follows a **Medallion Architecture** consisting of:

- 🥉 **Bronze Layer** — Raw source data
- 🥈 **Silver Layer** — Cleaned, standardized, and enriched data
- 🥇 **Gold Layer** — Business-ready analytical views

The final Gold layer follows a **Star Schema** containing customer and product dimensions surrounding a central sales fact table.

The project is designed to demonstrate practical **Data Engineering, ETL, Data Quality, Data Integration, and Data Modeling** concepts using SQL Server.

---

# 🎯 Project Objectives

The main objective is to build a reliable analytical data warehouse from multiple operational sources.

### Key objectives

- Ingest raw CRM and ERP data into SQL Server
- Preserve source data in a Bronze layer
- Clean and standardize inconsistent source data
- Remove duplicates and invalid records
- Handle missing and invalid values
- Normalize identifiers and categorical values
- Integrate information from CRM and ERP systems
- Apply business rules and derived logic
- Build analytical dimensions and fact tables
- Implement a Star Schema
- Validate data quality at multiple stages
- Document data lineage and architecture
- Provide a foundation for BI and analytical workloads

---

# 🧭 End-to-End Data Journey

```mermaid
flowchart LR

    A["📁 CRM Files"]
    B["📁 ERP Files"]

    A --> C["🥉 Bronze Layer"]
    B --> C

    C --> D["🧹 Cleansing"]

    D --> E["🏷️ Standardization"]

    E --> F["🔄 Normalization"]

    F --> G["🔗 Data Integration"]

    G --> H["💡 Business Rules"]

    H --> I["🥈 Silver Layer"]

    I --> J["👥 Customer Dimension"]
    I --> K["📦 Product Dimension"]
    I --> L["💰 Sales Fact"]

    J --> M["🥇 Gold Layer"]
    K --> M
    L --> M

    M --> N["📊 BI & Reporting"]
    M --> O["🔎 Ad-Hoc Analytics"]
    M --> P["🤖 Advanced Analytics"]
