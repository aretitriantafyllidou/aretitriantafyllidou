# 02_warehouse - Data Warehouse Creation Scripts

Create star schema data warehouse with fact and dimension tables.

## Scripts

### DWcreation.sql 
-  Complete star schema implementation
- Creates ChinookDW database
- **Fact Table**: FactInvoice
- **Dimensions**: DimArtist, DimAlbum, DimGenre, DimMediaType, DimCustomer, DimTrack
- **Features**: SCD Type 2 columns on DimCustomer (RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
- Foreign key constraints for referential integrity

## What It Creates

**Fact Table:**
- FactInvoice (InvoiceKey, InvoiceLineKey, ArtistKey, TrackKey, CustomerKey, InvoiceDateKey, Total, UnitPrice, Quantity)

**Dimension Tables:**
- DimArtist - Artist information
- DimAlbum - Album catalog (links to Artist)
- DimGenre - Music genres
- DimMediaType - Media format types
- DimCustomer - Customer data with SCD Type 2 support
- DimTrack - Track details (links to Album, Genre, MediaType)

All dimensions include SCD Type 2 columns for historical tracking.

## Execution Order
- Run staging script first (01_staging)
- Run DWcreation.sql to create warehouse structure
- Optionally run date dimension (05_utilities)
- Then run load script (03_load)

## Next Step
Go to 05_utilities (optional date dimension) or 03_load folder
