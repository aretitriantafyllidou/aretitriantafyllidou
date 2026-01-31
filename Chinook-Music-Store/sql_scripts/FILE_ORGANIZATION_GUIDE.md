# File Organization Guide

## How to Use These SQL Scripts

##  Folder Structure

```
sql_scripts/
│
├── README.md                     START HERE 
│
├── 01_staging/
│   ├── README.md                Explains staging scripts
│   ├── ChinookstagingMAIN.sql    Use this one
│   ├── ChinookStagingSIMPLE.sql    (alternative)
│   └── Staging3ENHANCED.sql        (alternative)
│
├── 02_warehouse/
│   ├── README.md                Explains warehouse creation
│   ├── DWcreation.sql             Use this one
│
├── 03_load/
│   ├── README.md               Explains load process
│   ├── MAINLoadDW.sql          Use this one
│   └── loadNEW__1_.sql         (alternative)
│
├── 04_scd/
│   ├── README.md               Explains SCD Type 2
│   ├── scdNEW__3_.sql           Use this one
│   └── SCD_Type2.sql           (alternative)
│
└── 05_utilities/
    ├── README.md                Explains date dimension
    ├── DimDate.sql              Use this one 
    └── DimDate__4_.sql         (alternative)
```

Alternative Scripts have some different approaches to same task. Some are simpler, some more complete


## Quick Copy-Paste Order

1. `01_staging/ChinookstagingMAIN.sql`
2. `02_warehouse/DWcreation.sql`
3. `05_utilities/DimDate.sql`
4. `03_load/MAINLoadDW.sql`
5. `04_scd/scdNEW__3_.sql`

Data warehouse is built.

 
