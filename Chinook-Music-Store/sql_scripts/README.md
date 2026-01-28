## SQL Scripts

Complete SQL scripts for building the Chinook music store data warehouse from scratch.


####  Folder Structure

```
sql_scripts/
├── 01_staging/          # Extract data from source to staging layer
├── 02_warehouse/        # Create star schema data warehouse
├── 03_load/             # Load data from staging to warehouse
├── 04_scd/              # Implement Slowly Changing Dimension Type 2
└── 05_utilities/        # Date dimension and helper scripts
```

###  Recommended Scripts 

If you just want to run the best scripts in order:

1. **01_staging/ChinookstagingNEW.sql** - Creates `ChinookStaging` database and extracts data from source.
2. **02_warehouse/DWcreation.sql** - Creates `ChinookDW` database with star schema (1 fact + 7 dimensions).
3. **05_utilities/DimDate.sql** - Generates comprehensive date dimension (990+ years) (optional but recommended)
4. **03_load/MainLoadDW.sql** - Loads dimensions first, then fact table from staging.
5. **04_scd/scdNEW__3_.sql** - Implements historical tracking for customer dimension. (optional but recommended)

Some folder contains alternative versions of scripts for  different approaches.

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

###  Important Notes

#### Load Order Matters
- **Always** load dimensions before fact table
- Fact table needs dimension keys (foreign keys)

#### First Load 
- Current scripts are for **initial load** (include DELETE statements)
- For production incremental loads, modify to use CDC or timestamp-based loading

#### SCD Type 2

- Currently implemented only on `DimCustomer`
- Can be extended to other dimensions (for example DimTrack for price changes)

### Testing Your Warehouse

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

**Check each folder's README before running scripts!**

### Re-running Scripts

#### To Start:
```sql
-- Drop databases (WARNING: Deletes all data!)
DROP DATABASE IF EXISTS ChinookStaging;
DROP DATABASE IF EXISTS ChinookDW;

-- Then re-run scripts from Step 1
```

#### To Reload Data Only:
```sql
-- Clear warehouse tables
USE ChinookDW;
DELETE FROM FactInvoice;
DELETE FROM DimArtist;
-- ... delete other dimensions

-- Then re-run load script (03_load)
```

###  Next Steps After Setup

1. **Connect Power BI** to ChinookDW database
2. **Run sample queries** (see `/sample_queries.sql` )
3. **Create dashboards** for sales analysis
4. **Test SCD Type 2** by changing customer data

