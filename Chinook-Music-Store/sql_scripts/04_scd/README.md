# 04_scd - Slowly Changing Dimension (SCD Type 2)

This script implement SCD Type 2 for tracking historical changes in customer data (for example address changes).

## Scripts

###  scdNEW__3_.sql 
- This use for a complete SCD Type 2 implementation
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

### What It Does
Truncates staging tables and reloads from source. Then it creates a staging dimension table with current data. Uses merge logic as:
 **MERGE logic**:
   - **MATCHED + Changed**: Expire old record
   - **NOT MATCHED (new)**: Insert new record
   - **NOT MATCHED BY SOURCE**: Soft delete
Then it inserts new versions of changed records with updated attributes.

### Execution Order
1. Warehouse must be loaded (`03_load`)
2. Run **scdNEW__3_.sql** to implement SCD Type 2
3. To test: Update a customer's city in source database, re-run script

### Next Step
Data warehouse is complete. Connect Power BI or run sample queries.
