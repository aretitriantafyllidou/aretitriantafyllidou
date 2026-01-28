# 03_load - ETL Load Scripts

This scripts load data from staging layer into data warehouse (dimensions first, then fact table).

### Scripts
MAINLoadDW.sql 
- Use this one as it has a complete ETL load process
- Matches with DWcreation.sql warehouse structure

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

### loadNEW__1_.sql (Alternative)
- Simpler load process
- Loads: DimArtist, DimCustomer, DimTrack, FactInvoice
- Good for basic warehouse without Album/Genre/MediaType
- Minor variations

### Important Notes
- Must load dimensions BEFORE fact table. Fact table needs dimension keys (CustomerKey, TrackKey, ArtistKey)
- First Load Only. These scripts include 'DELETE FROM' statements. They are designed for initial load, not incremental updates
- Match Your Staging Script.
- If you used ChinookStagingMAIN.sql → use MAINLoadDW.sql
- If you used staging3ENHANCED.sql → use loadNEW__1_.sql

### What Happens
- Dimensions get surrogate keys (auto-increment IDENTITY columns)
- Fact table gets populated with foreign keys pointing to dimensions

### Next Step
Go to 04_scd folder for slowly changing dimension implementation (but this isoptional)
