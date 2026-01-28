# 03_load - ETL Load Scripts

## Purpose
Load data from staging layer into data warehouse (dimensions first, then fact table).

## Scripts

### ⭐ ParisLoadDW.sql (RECOMMENDED)
- **Use this one**: Complete ETL load process
- Matches with `ParisDW.sql` warehouse structure
- **Loads in order**:
  1. DimArtist
  2. DimAlbum (requires Artist)
  3. DimMediaType
  4. DimGenre
  5. DimCustomer
  6. DimTrack (requires Album, MediaType, Genre)
  7. FactInvoice (requires all dimensions)
- Includes foreign key lookups
- Properly joins staging tables to warehouse dimensions

### load__1_.sql (Basic)
- Simpler load process
- Loads: DimArtist, DimCustomer, DimTrack, FactInvoice
- Good for basic warehouse without Album/Genre/MediaType

### loadNEW__1_.sql (Alternative)
- Similar to load__1_.sql
- Minor variations

## Important Notes

⚠️ **Load Order Matters!**
- Must load dimensions BEFORE fact table
- Fact table needs dimension keys (CustomerKey, TrackKey, ArtistKey)

⚠️ **First Load Only**
- These scripts include `DELETE FROM` statements
- They're designed for initial load, not incremental updates

⚠️ **Match Your Staging Script**
- If you used `ParisStaging__2_.sql` → use `ParisLoadDW.sql`
- If you used `ChinookstagingNEW.sql` → use `load__1_.sql` or `loadNEW__1_.sql`

## Execution Order
1. Staging must be populated (`01_staging`)
2. Warehouse structure must exist (`02_warehouse`)
3. Run **ParisLoadDW.sql** to load data
4. Optionally run SCD script (`04_scd`)

## What Happens
- Dimensions get surrogate keys (auto-increment IDENTITY columns)
- Fact table gets populated with foreign keys pointing to dimensions
- Data ready for querying!

## Next Step
Go to `04_scd` folder for slowly changing dimension implementation (optional)
