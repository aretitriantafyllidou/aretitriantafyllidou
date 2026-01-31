-- SAMPLE ANALYTICAL QUERIES
-- Chinook Data Warehouse

USE ChinookDW;
GO

--  TOP REVENUE ANALYSIS

-- Top 10 Artists by Revenue
SELECT TOP 10
    a.ArtistName,
    SUM(f.Total) as TotalRevenue,
    COUNT(DISTINCT f.InvoiceKey) as NumberOfInvoices,
    COUNT(*) as InvoiceLines
FROM FactInvoice f
INNER JOIN DimArtist a ON f.ArtistKey = a.ArtistKey
WHERE a.RowIsCurrent = 1
GROUP BY a.ArtistName
ORDER BY TotalRevenue DESC;

-- Top 10 Albums by Revenue
SELECT TOP 10
    alb.AlbumName,
    a.ArtistName,
    SUM(f.Total) as TotalRevenue,
    COUNT(*) as UnitsSold
FROM FactInvoice f
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimAlbum alb ON t.AlbumKey = alb.AlbumKey
INNER JOIN DimArtist a ON alb.ArtistKey = a.ArtistKey
GROUP BY alb.AlbumName, a.ArtistName
ORDER BY TotalRevenue DESC;

--  GEOGRAPHIC ANALYSIS
-- Revenue by Country
SELECT 
    c.CustomerCountry,
    COUNT(DISTINCT c.CustomerKey) as NumberOfCustomers,
    SUM(f.Total) as TotalRevenue,
    AVG(f.Total) as AvgOrderValue,
    COUNT(DISTINCT f.InvoiceKey) as NumberOfInvoices
FROM FactInvoice f
INNER JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.RowIsCurrent = 1
GROUP BY c.CustomerCountry
ORDER BY TotalRevenue DESC;

-- Revenue by City (Top 15)
SELECT TOP 15
    c.CustomerCity,
    c.CustomerCountry,
    SUM(f.Total) as TotalRevenue,
    COUNT(DISTINCT c.CustomerKey) as NumberOfCustomers
FROM FactInvoice f
INNER JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.RowIsCurrent = 1
GROUP BY c.CustomerCity, c.CustomerCountry
ORDER BY TotalRevenue DESC;

--  PRODUCT ANALYSIS

-- Genre Popularity and Revenue
SELECT 
    g.GenreName,
    COUNT(*) as UnitsSold,
    SUM(f.Total) as TotalRevenue,
    ROUND(AVG(f.UnitPrice), 2) as AvgPrice,
    COUNT(DISTINCT f.InvoiceKey) as NumberOfInvoices
FROM FactInvoice f
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimGenre g ON t.GenreKey = g.GenreKey
GROUP BY g.GenreName
ORDER BY TotalRevenue DESC;

-- Media Type Performance
SELECT 
    m.MediaTypeName,
    COUNT(*) as UnitsSold,
    SUM(f.Total) as TotalRevenue,
    ROUND(AVG(f.UnitPrice), 2) as AvgPrice
FROM FactInvoice f
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimMediaType m ON t.MediaTypeKey = m.MediaTypeKey
GROUP BY m.MediaTypeName
ORDER BY TotalRevenue DESC;

-- Top 20 Best-Selling Tracks
SELECT TOP 20
    t.TrackName,
    a.ArtistName,
    alb.AlbumName,
    COUNT(*) as TimesSold,
    SUM(f.Total) as TotalRevenue
FROM FactInvoice f
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimAlbum alb ON t.AlbumKey = alb.AlbumKey
INNER JOIN DimArtist a ON alb.ArtistKey = a.ArtistKey
GROUP BY t.TrackName, a.ArtistName, alb.AlbumName
ORDER BY TimesSold DESC;

--  TIME SERIES ANALYSIS

-- Monthly Sales Trend
SELECT 
    YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)) as Year,
    MONTH(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)) as Month,
    DATENAME(MONTH, CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)) as MonthName,
    SUM(Total) as MonthlyRevenue,
    COUNT(DISTINCT InvoiceKey) as NumberOfInvoices,
    COUNT(*) as InvoiceLines
FROM FactInvoice
GROUP BY 
    YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)),
    MONTH(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)),
    DATENAME(MONTH, CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE))
ORDER BY Year, Month;

-- Quarterly Sales
SELECT 
    YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)) as Year,
    DATEPART(QUARTER, CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)) as Quarter,
    SUM(Total) as QuarterlyRevenue,
    COUNT(DISTINCT InvoiceKey) as NumberOfInvoices
FROM FactInvoice
GROUP BY 
    YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)),
    DATEPART(QUARTER, CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE))
ORDER BY Year, Quarter;

-- Year over Year Growth
WITH YearlyRevenue AS (
    SELECT 
        YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)) as Year,
        SUM(Total) as Revenue
    FROM FactInvoice
    GROUP BY YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE))
)
SELECT 
    Year,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year) as PreviousYearRevenue,
    Revenue - LAG(Revenue) OVER (ORDER BY Year) as Growth,
    CASE 
        WHEN LAG(Revenue) OVER (ORDER BY Year) IS NOT NULL 
        THEN ROUND(((Revenue - LAG(Revenue) OVER (ORDER BY Year)) / LAG(Revenue) OVER (ORDER BY Year)) * 100, 2)
        ELSE NULL
    END as GrowthPercentage
FROM YearlyRevenue
ORDER BY Year;

-- CUSTOMER ANALYSIS

-- High-Value Customers (Top 20)
SELECT TOP 20
    c.FirstName + ' ' + c.LastName as CustomerName,
    c.CustomerCountry,
    c.CustomerCity,
    COUNT(DISTINCT f.InvoiceKey) as TotalOrders,
    SUM(f.Total) as TotalSpent,
    AVG(f.Total) as AvgOrderValue,
    MIN(CAST(CAST(f.InvoiceDateKey AS VARCHAR(8)) AS DATE)) as FirstPurchase,
    MAX(CAST(CAST(f.InvoiceDateKey AS VARCHAR(8)) AS DATE)) as LastPurchase
FROM FactInvoice f
INNER JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.RowIsCurrent = 1
GROUP BY c.CustomerKey, c.FirstName, c.LastName, c.CustomerCountry, c.CustomerCity
ORDER BY TotalSpent DESC;

-- Customer Purchase Frequency
SELECT 
    CASE 
        WHEN OrderCount = 1 THEN '1 Order'
        WHEN OrderCount BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN OrderCount BETWEEN 6 AND 10 THEN '6-10 Orders'
        ELSE '11+ Orders'
    END as PurchaseFrequency,
    COUNT(*) as NumberOfCustomers,
    SUM(TotalSpent) as TotalRevenue,
    AVG(TotalSpent) as AvgRevenuePerCustomer
FROM (
    SELECT 
        c.CustomerKey,
        COUNT(DISTINCT f.InvoiceKey) as OrderCount,
        SUM(f.Total) as TotalSpent
    FROM FactInvoice f
    INNER JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
    WHERE c.RowIsCurrent = 1
    GROUP BY c.CustomerKey
) as CustomerStats
GROUP BY 
    CASE 
        WHEN OrderCount = 1 THEN '1 Order'
        WHEN OrderCount BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN OrderCount BETWEEN 6 AND 10 THEN '6-10 Orders'
        ELSE '11+ Orders'
    END
ORDER BY 
    CASE 
        WHEN PurchaseFrequency = '1 Order' THEN 1
        WHEN PurchaseFrequency = '2-5 Orders' THEN 2
        WHEN PurchaseFrequency = '6-10 Orders' THEN 3
        ELSE 4
    END;

--  SCD TYPE 2 DEMO

-- Customer History (showing address changes)
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName as CustomerName,
    c.CustomerCity,
    c.CustomerCountry,
    c.RowIsCurrent,
    c.RowStartDate,
    c.RowEndDate,
    c.RowChangeReason,
    COUNT(f.InvoiceLineKey) as InvoicesInThisLocation,
    SUM(f.Total) as RevenueInThisLocation
FROM DimCustomer c
LEFT JOIN FactInvoice f ON c.CustomerKey = f.CustomerKey
WHERE c.CustomerID IN (
    -- Find customers with history (multiple records)
    SELECT CustomerID 
    FROM DimCustomer 
    GROUP BY CustomerID 
    HAVING COUNT(*) > 1
)
GROUP BY 
    c.CustomerID, c.FirstName, c.LastName, c.CustomerCity, c.CustomerCountry,
    c.RowIsCurrent, c.RowStartDate, c.RowEndDate, c.RowChangeReason
ORDER BY c.CustomerID, c.RowStartDate;

-- Current vs Historical Customer Records
SELECT 
    CASE 
        WHEN RowIsCurrent = 1 THEN 'Current'
        ELSE 'Historical'
    END as RecordType,
    COUNT(*) as NumberOfRecords
FROM DimCustomer
GROUP BY RowIsCurrent;

--  ARTIST-ALBUM-TRACK DRILL-DOWN
-- Complete drill-down analysis
SELECT 
    art.ArtistName,
    alb.AlbumName,
    t.TrackName,
    g.GenreName,
    m.MediaTypeName,
    COUNT(f.InvoiceLineKey) as TimesSold,
    SUM(f.Quantity) as TotalQuantity,
    SUM(f.Total) as TotalRevenue,
    AVG(f.UnitPrice) as AvgPrice
FROM FactInvoice f
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimAlbum alb ON t.AlbumKey = alb.AlbumKey
INNER JOIN DimArtist art ON f.ArtistKey = art.ArtistKey
INNER JOIN DimGenre g ON t.GenreKey = g.GenreKey
INNER JOIN DimMediaType m ON t.MediaTypeKey = m.MediaTypeKey
WHERE art.RowIsCurrent = 1
GROUP BY art.ArtistName, alb.AlbumName, t.TrackName, g.GenreName, m.MediaTypeName
ORDER BY TotalRevenue DESC;

--  INSIGHTS
-- Average Order Value Over Time
SELECT 
    YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE)) as Year,
    AVG(InvoiceTotal) as AvgOrderValue
FROM (
    SELECT 
        InvoiceDateKey,
        InvoiceKey,
        SUM(Total) as InvoiceTotal
    FROM FactInvoice
    GROUP BY InvoiceDateKey, InvoiceKey
) as InvoiceTotals
GROUP BY YEAR(CAST(CAST(InvoiceDateKey AS VARCHAR(8)) AS DATE))
ORDER BY Year;

-- Revenue Concentration
WITH ArtistRevenue AS (
    SELECT 
        a.ArtistName,
        SUM(f.Total) as Revenue,
        SUM(SUM(f.Total)) OVER () as TotalRevenue
    FROM FactInvoice f
    INNER JOIN DimArtist a ON f.ArtistKey = a.ArtistKey
    GROUP BY a.ArtistName
)
SELECT 
    ArtistName,
    Revenue,
    ROUND((Revenue / TotalRevenue) * 100, 2) as PercentOfTotal,
    ROUND(SUM(Revenue) OVER (ORDER BY Revenue DESC) / TotalRevenue * 100, 2) as CumulativePercent
FROM ArtistRevenue
ORDER BY Revenue DESC;

-- Genre Popularity by Country
SELECT 
    c.CustomerCountry,
    g.GenreName,
    COUNT(*) as UnitsSold,
    SUM(f.Total) as Revenue,
    ROW_NUMBER() OVER (PARTITION BY c.CustomerCountry ORDER BY SUM(f.Total) DESC) as Rank
FROM FactInvoice f
INNER JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimGenre g ON t.GenreKey = g.GenreKey
WHERE c.RowIsCurrent = 1
GROUP BY c.CustomerCountry, g.GenreName
HAVING ROW_NUMBER() OVER (PARTITION BY c.CustomerCountry ORDER BY SUM(f.Total) DESC) <= 3
ORDER BY c.CustomerCountry, Rank;

--  CHECKS
-- Check for NULL values in fact table
SELECT 
    'InvoiceKey' as ColumnName,
    COUNT(*) as NullCount
FROM FactInvoice
WHERE InvoiceKey IS NULL
UNION ALL
SELECT 'CustomerKey', COUNT(*) FROM FactInvoice WHERE CustomerKey IS NULL
UNION ALL
SELECT 'TrackKey', COUNT(*) FROM FactInvoice WHERE TrackKey IS NULL
UNION ALL
SELECT 'ArtistKey', COUNT(*) FROM FactInvoice WHERE ArtistKey IS NULL
UNION ALL
SELECT 'Total', COUNT(*) FROM FactInvoice WHERE Total IS NULL;

-- Verify referential integrity
SELECT 
    'Orphaned CustomerKeys' as Issue,
    COUNT(*) as Count
FROM FactInvoice f
LEFT JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL
UNION ALL
SELECT 
    'Orphaned TrackKeys',
    COUNT(*)
FROM FactInvoice f
LEFT JOIN DimTrack t ON f.TrackKey = t.TrackKey
WHERE t.TrackKey IS NULL
UNION ALL
SELECT 
    'Orphaned ArtistKeys',
    COUNT(*)
FROM FactInvoice f
LEFT JOIN DimArtist a ON f.ArtistKey = a.ArtistKey
WHERE a.ArtistKey IS NULL;

--  STATISTICS

-- Overall warehouse statistics
SELECT 
    'Total Revenue' as Metric,
    FORMAT(SUM(Total), 'C', 'en-US') as Value
FROM FactInvoice
UNION ALL
SELECT 'Total Invoices', CAST(COUNT(DISTINCT InvoiceKey) AS VARCHAR)
FROM FactInvoice
UNION ALL
SELECT 'Total Invoice Lines', CAST(COUNT(*) AS VARCHAR)
FROM FactInvoice
UNION ALL
SELECT 'Average Order Value', FORMAT(AVG(InvoiceTotal), 'C', 'en-US')
FROM (
    SELECT InvoiceKey, SUM(Total) as InvoiceTotal
    FROM FactInvoice
    GROUP BY InvoiceKey
) as InvoiceTotals
UNION ALL
SELECT 'Number of Customers', CAST(COUNT(DISTINCT CustomerKey) AS VARCHAR)
FROM DimCustomer
WHERE RowIsCurrent = 1
UNION ALL
SELECT 'Number of Artists', CAST(COUNT(*) AS VARCHAR)
FROM DimArtist
WHERE RowIsCurrent = 1
UNION ALL
SELECT 'Number of Tracks', CAST(COUNT(*) AS VARCHAR)
FROM DimTrack
WHERE RowIsCurrent = 1;
