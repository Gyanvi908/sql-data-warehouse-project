# 🏗️ Enterprise Sales Data Warehouse & Analytics Platform

<p align="center">
  <img src="docs/data_architecture.png" alt="High Level Data Warehouse Architecture" width="100%">
</p>

<h1 align="center">
  From Raw Operational Data to Business-Ready Analytics
</h1>

<p align="center">
  <strong>
    An end-to-end SQL Server Data Warehouse project demonstrating
    data ingestion, ETL, data cleansing, standardization, integration,
    data quality engineering, dimensional modeling, and analytical data serving.
  </strong>
</p>

<br>

<p align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-Data%20Warehouse-red?style=for-the-badge&logo=microsoftsqlserver)

![T-SQL](https://img.shields.io/badge/T--SQL-ETL-blue?style=for-the-badge)

![Architecture](https://img.shields.io/badge/Architecture-Medallion-orange?style=for-the-badge)

![Data Model](https://img.shields.io/badge/Data%20Model-Star%20Schema-yellow?style=for-the-badge)

![Data Quality](https://img.shields.io/badge/Data%20Quality-Validated-success?style=for-the-badge)

![Git](https://img.shields.io/badge/Version%20Control-Git-black?style=for-the-badge&logo=git)

![GitHub](https://img.shields.io/badge/Repository-GitHub-black?style=for-the-badge&logo=github)

</p>

---

# 📌 Table of Contents

- [🌟 Project Overview](#-project-overview)
- [🎯 Business Problem](#-business-problem)
- [💡 Project Objective](#-project-objective)
- [🏛️ Architecture](#️-architecture)
- [🔄 End-to-End Data Flow](#-end-to-end-data-flow)
- [📥 Source Systems](#-source-systems)
- [🥉 Bronze Layer](#-bronze-layer)
- [🥈 Silver Layer](#-silver-layer)
- [🥇 Gold Layer](#-gold-layer)
- [🔗 CRM and ERP Integration](#-crm-and-erp-integration)
- [🧹 Data Quality Engineering](#-data-quality-engineering)
- [⭐ Star Schema](#-star-schema)
- [👥 Customer Dimension](#-customer-dimension)
- [📦 Product Dimension](#-product-dimension)
- [💰 Sales Fact](#-sales-fact)
- [🧬 Data Lineage](#-data-lineage)
- [⚙️ ETL Pipeline](#️-etl-pipeline)
- [📊 Data Validation Results](#-data-validation-results)
- [📚 Project Documentation](#-project-documentation)
- [📁 Repository Structure](#-repository-structure)
- [🧰 Technology Stack](#-technology-stack)
- [🚀 How to Run the Project](#-how-to-run-the-project)
- [🔍 Analytical Capabilities](#-analytical-capabilities)
- [📈 BI and Reporting Opportunities](#-bi-and-reporting-opportunities)
- [🧠 Engineering Decisions](#-engineering-decisions)
- [🛡️ Reliability and Error Handling](#️-reliability-and-error-handling)
- [⚡ Performance Considerations](#-performance-considerations)
- [🔮 Future Enhancements](#-future-enhancements)
- [🏆 Project Outcomes](#-project-outcomes)
- [📝 Learning Outcomes](#-learning-outcomes)
- [✅ Project Completion](#-project-completion)
- [👤 Author](#-author)

---

# 🌟 Project Overview

Modern organizations rarely have all of their information stored in one system.

Customer information may exist in a CRM.

Product information may exist in a product management system.

Geographic information may exist in an ERP.

Sales transactions may come from another operational system.

The challenge is therefore not simply storing data.

The real challenge is:

> **How do we transform fragmented operational data into reliable, consistent, integrated, and business-ready analytical information?**

This project addresses that problem by building an **end-to-end SQL Server Data Warehouse** using a layered architecture.

The project integrates data originating from:

- CRM systems
- ERP systems

and processes it through:

```text
RAW SOURCE DATA
       │
       ▼
🥉 BRONZE
Raw / Source-Aligned Data
       │
       ▼
🥈 SILVER
Cleaned / Standardized / Integrated Data
       │
       ▼
🥇 GOLD
Business-Ready Analytical Data
       │
       ▼
⭐ STAR SCHEMA
       │
       ▼
BI • Reporting • SQL • Data Science
