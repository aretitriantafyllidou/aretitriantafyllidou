# SQL Scripts - Chinook Data Warehouse

Complete SQL scripts for building the Chinook music store data warehouse from scratch.

---

## 📁 Folder Structure

```
sql_scripts/
├── 01_staging/          # Extract data from source to staging layer
├── 02_warehouse/        # Create star schema data warehouse
├── 03_load/             # Load data from staging to warehouse
├── 04_scd/              # Implement Slowly Changing Dimension Type 2
└── 05_utilities/        # Date dimension and helper scripts
```

---

## 🚀 Quick Start Guide

### Prerequisites
- SQL Server 2016+ or SQL Server Express
- SQL Server Management Studio (SSMS)
- Chinook database restored and running

### Execution Order (Follow These Steps)

#### **Step 1: Staging Layer**
```
📂 01_staging/
   Run: ChinookstagingNEW.sql
```
Creates `ChinookStaging` database and extracts data from source.

#### **Step 2: Data Warehouse**
```
📂 02_warehouse/
   Run: ParisDW.sql
```
Creates `ChinookDW` database with star schema (1 fact + 7 dimensions).

#### **Step 3: Date Dimension** (Optional but Recommended)
```
📂 05_utilities/
   Run: DimDate.sql
```
Generates comprehensive date dimension (990+ years).

#### **Step 4: Load Data**
```
📂 03_load/
   Run: ParisLoadDW.sql
```
Loads dimensions first, then fact table from staging.

#### **Step 5: SCD Type 2** (Optional but Recommended)
```
📂 04_scd/
   Run: scdNEW__3_.sql
```
Implements historical tracking for customer dimension.

---

## ⭐ Recommended Scripts (Copy-Paste Order)

If you just want to run the best scripts in order:

1. **01_staging/ChinookstagingNEW.sql** - Staging layer
2. **02_warehouse/ParisDW.sql** - Star schema
3. **05_utilities/DimDate.sql** - Date dimension
4. **03_load/ParisLoadDW.sql** - Load data
5. **04_scd/scdNEW__3_.sql** - SCD Type 2

**Total execution time**: ~5-10 minutes

---

## 📊 What Gets Created

### Databases
- `ChinookStaging` - Staging layer for ETL
- `ChinookDW` - Data warehouse with star schema

### Tables in ChinookDW

**Fact Table:**
- `FactInvoice` (2,240+ transaction records)

**Dimension Tables:**
- `DimArtist` (275 artists)
- `DimAlbum` (347 albums)
- `DimGenre` (25 genres)
- `DimMediaType` (5 media types)
- `DimCustomer` (59 customers with SCD Type 2)
- `DimTrack` (3,503 tracks)
- `DimDate` (361,000+ date records spanning 990 years)

---

## 🔧 Alternative Scripts

Each folder contains alternative versions of scripts:
- Use these if you want different approaches
- Primary (recommended) scripts are marked with ⭐ in each folder's README
- All scripts are functional, just slightly different implementations

---

## ⚠️ Important Notes

### Load Order Matters
- **Always** load dimensions before fact table
- Fact table needs dimension keys (foreign keys)

### First Load vs Incremental
- Current scripts are for **initial load** (include DELETE statements)
- For production incremental loads, modify to use CDC or timestamp-based loading

### SCD Type 2
- Currently implemented only on `DimCustomer`
- Can be extended to other dimensions (e.g., DimTrack for price changes)

### Date Dimension
- Takes ~30-60 seconds to populate
- Optional but highly recommended for temporal analysis

---

## 🧪 Testing Your Warehouse

After running all scripts, verify everything worked:

```sql
-- Check row counts
USE ChinookDW;

SELECT 'FactInvoice' as TableName, COUNT(*) as RowCount FROM FactInvoice
UNION ALL SELECT 'DimArtist', COUNT(*) FROM DimArtist
UNION ALL SELECT 'DimAlbum', COUNT(*) FROM DimAlbum
UNION ALL SELECT 'DimGenre', COUNT(*) FROM DimGenre
UNION ALL SELECT 'DimMediaType', COUNT(*) FROM DimMediaType
UNION ALL SELECT 'DimCustomer', COUNT(*) FROM DimCustomer
UNION ALL SELECT 'DimTrack', COUNT(*) FROM DimTrack
UNION ALL SELECT 'DimDate', COUNT(*) FROM DimDate;

-- Expected results:
-- FactInvoice: ~2,240
-- DimArtist: ~275
-- DimAlbum: ~347
-- DimGenre: ~25
-- DimMediaType: ~5
-- DimCustomer: ~59
-- DimTrack: ~3,503
-- DimDate: ~361,000
```

### Sample Query
```sql
-- Top 5 artists by revenue
SELECT TOP 5
    a.ArtistName,
    SUM(f.Total) as TotalRevenue
FROM FactInvoice f
INNER JOIN DimArtist a ON f.ArtistKey = a.ArtistKey
GROUP BY a.ArtistName
ORDER BY TotalRevenue DESC;
```

---

## 📚 Documentation

Each folder contains its own README with:
- Purpose of scripts
- Detailed explanations
- Execution instructions
- What gets created
- Important notes

**Check each folder's README before running scripts!**

---

## 🔄 Re-running Scripts

### To Start Fresh:
```sql
-- Drop databases (WARNING: Deletes all data!)
DROP DATABASE IF EXISTS ChinookStaging;
DROP DATABASE IF EXISTS ChinookDW;

-- Then re-run scripts from Step 1
```

### To Reload Data Only:
```sql
-- Clear warehouse tables
USE ChinookDW;
DELETE FROM FactInvoice;
DELETE FROM DimArtist;
-- ... delete other dimensions

-- Then re-run load script (03_load)
```

---

## 🎯 Next Steps After Setup

1. **Connect Power BI** to ChinookDW database
2. **Run sample queries** (see `/samples/sample_queries.sql` in main repo)
3. **Create dashboards** for sales analysis
4. **Test SCD Type 2** by changing customer data

---

## 📞 Need Help?

- Check individual folder READMEs for detailed instructions
- Review main project documentation in repository root
- Verify prerequisites are installed correctly
- Check SQL Server error messages for specific issues

---

**Your data warehouse is ready to power business intelligence! 🚀**
