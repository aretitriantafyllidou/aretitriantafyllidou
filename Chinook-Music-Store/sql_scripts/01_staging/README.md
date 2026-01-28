# 01_staging - Staging Layer Scripts

## Purpose
Extract data from source Chinook database into staging layer for validation and transformation.

## Scripts

### ChinookstagingMAIN.sql (RECOMMENDED)
- **Use this one**: Primary staging script
- Creates `ChinookStaging` database
- Extracts: Artist, Customer, Track, InvoiceDetails
- Includes: Date key generation (InvoiceDateKey)
- Clean and complete

### staging3ENHANCED.sql (Alternative)
- Enhanced version with additional dimensions
- Extracts: Artist, Album, Genre, MediaType, Customer, Track, InvoiceDetails
- Includes: Album, Genre, MediaType as separate tables
- Use if you want more granular dimensions

### ChinookStagingSIMPLE.sql (Basic)
- Simpler staging version
- Extracts: Artist, Customer, Track, InvoiceDetails
- No Album/Genre/MediaType separation
- Good for basic implementation

## Execution Order
Run ONE of these scripts (better choice is ChinookstagingMAIN.sql)

## Next Step
After running staging, go to `02_warehouse` folder
