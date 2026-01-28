# 04_scd - Slowly Changing Dimension (SCD Type 2)

## Purpose
Implement SCD Type 2 for tracking historical changes in customer data (e.g., address changes).

## Scripts

### ⭐ scdNEW__3_.sql (RECOMMENDED)
- **Use this one**: Complete SCD Type 2 implementation
- Uses MERGE statement for efficient processing
- Handles:
  - **New customers**: Insert with RowIsCurrent=1
  - **Changed customers**: Expire old record (RowIsCurrent=0), insert new version
  - **Deleted customers**: Soft delete (RowIsCurrent=0, RowChangeReason='SOFT DELETE')
- Includes foreign key constraint management
- Clean and well-commented

### SCD_Type2.sql (Alternative)
- Similar implementation
- Slightly different approach
- Use scdNEW__3_.sql for consistency

## How SCD Type 2 Works

### Before Customer Moves:
```
CustomerKey | CustomerID | City      | RowIsCurrent | RowStartDate | RowEndDate
------------|------------|-----------|--------------|--------------|------------
1           | 101        | London    | 1            | 2020-01-01   | 9999-12-31
```

### After Customer Moves to Paris:
```
CustomerKey | CustomerID | City      | RowIsCurrent | RowStartDate | RowEndDate
------------|------------|-----------|--------------|--------------|------------
1           | 101        | London    | 0            | 2020-01-01   | 2023-06-30
2           | 101        | Paris     | 1            | 2023-07-01   | 9999-12-31
```

Now you can answer: "Where did CustomerID 101 live in 2022?" → London!

## What It Does

1. **Truncates staging tables** and reloads from source
2. **Creates staging dimension table** with current data
3. **MERGE logic**:
   - **MATCHED + Changed**: Expire old record
   - **NOT MATCHED (new)**: Insert new record
   - **NOT MATCHED BY SOURCE**: Soft delete
4. **Inserts new versions** of changed records with updated attributes

## Execution Order
1. Warehouse must be loaded (`03_load`)
2. Run **scdNEW__3_.sql** to implement SCD Type 2
3. To test: Update a customer's city in source database, re-run script

## Important Notes

⚠️ **Foreign Key Constraints**
- Script temporarily disables foreign key on FactInvoice
- Re-enables it after MERGE operation
- This prevents constraint violations during update

⚠️ **ETL Date**
- Script uses `@etldate = '1998-05-07'` as example
- Change this to your actual ETL run date

⚠️ **Only Applies to DimCustomer**
- Currently tracks customer city changes
- Can be extended to other dimensions (DimTrack for price changes, etc.)

## Testing SCD Type 2

```sql
-- 1. Load initial data
-- Run: 01_staging, 02_warehouse, 03_load

-- 2. Run SCD script
-- Run: scdNEW__3_.sql

-- 3. Change customer city in source
USE Chinook;
UPDATE Customer SET City = 'New York' WHERE CustomerID = 1;

-- 4. Re-run SCD script
-- Run: scdNEW__3_.sql again

-- 5. Check results
USE ChinookDW;
SELECT * FROM DimCustomer WHERE CustomerID = 1 ORDER BY RowStartDate;
-- You should see 2 records: old city (expired) + new city (current)
```

## Next Step
Data warehouse is complete! Connect Power BI or run sample queries.
