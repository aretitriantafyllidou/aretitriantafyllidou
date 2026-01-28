# 02_warehouse - Data Warehouse Creation Scripts

## Purpose
Create star schema data warehouse with fact and dimension tables.

## Scripts

### ⭐ ParisDW.sql (RECOMMENDED)
- **Use this one**: Complete star schema implementation
- Creates `ChinookDW` database
- **Fact Table**: FactInvoice
- **Dimensions**: DimArtist, DimAlbum, DimGenre, DimMediaType, DimCustomer, DimTrack
- **Features**: SCD Type 2 columns on DimCustomer (RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
- Foreign key constraints for referential integrity

### ParisDW__1_.sql (Alternative)
- Same structure as ParisDW.sql
- Slight variations (use ParisDW.sql for consistency)

## What It Creates

**Fact Table:**
- `FactInvoice` (InvoiceKey, InvoiceLineKey, ArtistKey, TrackKey, CustomerKey, InvoiceDateKey, Total, UnitPrice, Quantity)

**Dimension Tables:**
1. `DimArtist` - Artist information
2. `DimAlbum` - Album catalog (links to Artist)
3. `DimGenre` - Music genres
4. `DimMediaType` - Media format types
5. `DimCustomer` - Customer data with SCD Type 2 support
6. `DimTrack` - Track details (links to Album, Genre, MediaType)

All dimensions include SCD Type 2 columns for historical tracking.

## Execution Order
1. Run staging script first (`01_staging`)
2. Run **ParisDW.sql** to create warehouse structure
3. Optionally run date dimension (`05_utilities`)
4. Then run load script (`03_load`)

## Next Step
Go to `05_utilities` (optional date dimension) or `03_load` folder
