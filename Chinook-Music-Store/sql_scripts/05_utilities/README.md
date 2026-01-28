# 05_utilities - Date Dimension & Helper Scripts

## Purpose
Generate comprehensive date dimension table for temporal analysis.

## Scripts

### ⭐ DimDate.sql (RECOMMENDED - formerly SQLQuery5.sql)
- **Use this one**: Comprehensive date dimension generator
- Creates `DimDate` table in `ChinookDW` database
- **Date Range**: 2009-01-01 to 2999-12-31 (990+ years)
- **Attributes**: 30+ calculated fields

### DimDate__4_.sql (Alternative)
- Similar implementation
- Use DimDate.sql for consistency

## What It Creates

### Date Dimension Table Structure

**Primary Key**: `DateKey` (INT) - Format: YYYYMMDD (e.g., 20230615)

**Date Attributes**:
- `Date` - Full datetime value
- `FullDateUK` / `FullDateUSA` - Formatted date strings
- `DayOfMonth`, `DayName`, `DayOfWeek`
- `WeekOfMonth`, `WeekOfQuarter`, `WeekOfYear`
- `Month`, `MonthName`, `MonthOfQuarter`
- `Quarter`, `QuarterName`
- `Year`, `YearName`
- `FirstDayOfMonth`, `LastDayOfMonth`
- `FirstDayOfQuarter`, `LastDayOfQuarter`
- `FirstDayOfYear`, `LastDayOfYear`

**Holiday Flags**:
- `IsHolidayUSA` - Flag for US holidays
- `HolidayUSA` - Name of US holiday
- `IsHolidayUK` - Flag for UK holidays
- `HolidayUK` - Name of UK holiday
- `IsWeekday` - Flag (1=weekday, 0=weekend)

**US Holidays Included**:
- New Year's Day, Martin Luther King Jr Day, President's Day
- Valentine's Day, Saint Patrick's Day
- Mother's Day, Father's Day
- Memorial Day, Independence Day, Labor Day
- Halloween, Thanksgiving, Christmas, Election Day

**UK Holidays Included**:
- New Year's Day, Good Friday, Easter Monday
- Early May Bank Holiday, Spring Bank Holiday, Summer Bank Holiday
- Christmas Day, Boxing Day

## Why Use Date Dimension?

### Benefits:
1. **Pre-calculated attributes** - No need to calculate day/month/quarter in queries
2. **Integer keys** - Faster joins (4 bytes vs 8 bytes for DATETIME)
3. **Holiday analysis** - Easy filtering for holiday vs non-holiday sales
4. **Fiscal periods** - Support for fiscal year reporting
5. **Performance** - Indexed date keys speed up temporal queries

### Example Queries Enabled:
```sql
-- Sales by quarter
SELECT d.Quarter, SUM(f.Total) 
FROM FactInvoice f
JOIN DimDate d ON f.InvoiceDateKey = d.DateKey
GROUP BY d.Quarter;

-- Weekend vs weekday sales
SELECT d.IsWeekday, SUM(f.Total)
FROM FactInvoice f
JOIN DimDate d ON f.InvoiceDateKey = d.DateKey
GROUP BY d.IsWeekday;

-- Holiday sales
SELECT d.HolidayUSA, SUM(f.Total)
FROM FactInvoice f
JOIN DimDate d ON f.InvoiceDateKey = d.DateKey
WHERE d.IsHolidayUSA = 1
GROUP BY d.HolidayUSA;
```

## Execution Order
1. Warehouse structure must exist (`02_warehouse`)
2. Run **DimDate.sql** (can be run anytime after warehouse creation)
3. This is **optional** but highly recommended for temporal analysis

## Performance Notes
- Script uses WHILE loop to generate dates
- Takes ~30-60 seconds to populate 990 years of dates
- Generates ~361,000+ date records
- Creates holiday flags dynamically

## Customization
You can modify:
- **Date range**: Change `@StartDate` and `@EndDate` variables (lines 10-11)
- **Holidays**: Add/remove holidays by modifying UPDATE statements (lines 243-456)
- **Fiscal year**: Add custom fiscal period logic if needed

## Next Step
Date dimension is ready! Proceed to load data (`03_load`) or connect Power BI.
