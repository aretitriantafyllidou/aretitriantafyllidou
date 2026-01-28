# Chinook Music Store Data Warehouse - ETL Pipeline Project

### Project Overview

This is a project that presents a complete ETL (Extract, Transform, Load) pipeline implementation for a digital music store database. It implements a dimensional modeling with star schema, slowly changing dimensions, and Power BI dashboards for business intelligence.
The main goal was to transform the Chinook database into an analytical data warehouse that tracks sales performance, customer behavior and product trends across artists, albums, genres, and geographic regions.


### Dataset

**Source**: Chinook Database - sample database that represents a digital music store  
**Domain**: Music retail (artists, albums, tracks, customers, invoices)  
**Scale**: 2,240 invoice lines | 412 invoices | 59 customers | 275 artists | 3,503 tracks  
 
> *The Chinook database is an open-source sample database.*

### Key Features

* **Star Schema Design** - 1 fact table + 7 dimension tables 
* **SCD Type 2 Implementation** - Historical customer tracking 
* **Date Dimension** - 990+ years with holidays, fiscal periods, and weekday flags
* **Three-Layer ETL Pipeline** - Source, Staging, Warehouse with data quality checks
* **Power BI** - Interactive dashboards for sales and customer analytics

### Data Warehouse Schema

**Fact Table**: `FactInvoice` (transaction records)  
**Dimensions**: Customer, Artist, Album, Track, Genre, MediaType, Date

### ETL process

- Extract: Data pulled from operational Chinook database into staging layer.
- Transform: Date keys generated, NULL values handled, Invoice tables denormalized, and business rules applied.
- Load: Dimensions loaded first to establish surrogate keys, then fact table populated with SCD Type 2 applied.

### Business Insights 

- Sales Analysis: Top revenue-generating artists/albums/genres, product performance metrics, and genre popularity by region.
- Customer Intelligence: Geographic revenue distribution, customer lifetime value, purchase patterns, and historical address tracking.
- Temporal Analysis: Monthly/quarterly/yearly trends, seasonality identification, year-over-year growth, and weekend vs weekday behavior.

### Power BI Dashboards

Interactive dashboards for sales performance, customer analytics, product analysis, and temporal trends with drill-down capabilities.

### Sample Queries

The warehouse supports analytical queries such as:
- "Which artists generate the most revenue?"
- "What percentage of sales come from each country?"
- "What are the top-selling genres by region?"
- "What is the month-over-month revenue growth rate?"
- "How many customers changed locations, and when?"

**Technologies Used:** SQL Server, T-SQL, Power BI, Data Modeling, ETL Development, Kimball dimensional modeling methodology 

### Prerequisites
- SQL Server 2016+ or SQL Server Express
- SQL Server Management Studio (SSMS)
- [Chinook Database](https://github.com/lerocha/chinook-database)
- Power BI Desktop (optional, for dashboards)

### Certification

**ReGeneration Academy - Business Intelligence & Data Engineering**  
Certificate No: 24C015184 | 100-hour program (Nov 2023 - Jan 2024)  
Academic Partner: Athens University of Economics and Business
Methodology: Ralph Kimball's dimensional modeling principles

*Topics: Dimensional Modeling, ETL Development, SQL Server, Power BI, Data Warehousing*


