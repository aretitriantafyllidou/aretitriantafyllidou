--Sample queries for Chinook data warehouse

USE ChinookDW;
GO

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


-- Revenue by Country

SELECT 
    c.CustomerCountry,
    COUNT(DISTINCT c.CustomerKey) as Customers,
    SUM(f.Total) as Revenue,
    AVG(f.Total) as AvgOrderValue
FROM FactInvoice f
INNER JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.RowIsCurrent = 1
GROUP BY c.CustomerCountry
ORDER BY Revenue DESC;

-- Genre Popularity and Revenue

SELECT 
    g.GenreName,
    COUNT(*) as UnitsSold,
    SUM(f.Total) as Revenue,
    ROUND(AVG(f.UnitPrice), 2) as AvgPrice
FROM FactInvoice f
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimGenre g ON t.GenreKey = g.GenreKey
GROUP BY g.GenreName
ORDER BY Revenue DESC;

-- time series analysis -monthly sales trend-

SELECT 
    d.Year,
    d.MonthName,
    SUM(f.Total) as MonthlyRevenue,
    COUNT(DISTINCT f.InvoiceKey) as Invoices
FROM FactInvoice f
INNER JOIN DimDate d ON f.InvoiceDateKey = d.DateKey
GROUP BY d.Year, d.Month, d.MonthName
ORDER BY d.Year, d.Month;

-- scd type 2
-- Customer History (showing address changes)

SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName as CustomerName,
    c.CustomerCity,
    c.RowIsCurrent,
    c.RowStartDate,
    c.RowEndDate,
    c.RowChangeReason,
    SUM(f.Total) as RevenueInThisLocation
FROM DimCustomer c
LEFT JOIN FactInvoice f ON c.CustomerKey = f.CustomerKey
WHERE c.CustomerID IN (
    SELECT CustomerID 
    FROM DimCustomer 
    GROUP BY CustomerID 
    HAVING COUNT(*) > 1  -- Customers with history
)
GROUP BY 
    c.CustomerID, c.FirstName, c.LastName, c.CustomerCity,
    c.RowIsCurrent, c.RowStartDate, c.RowEndDate, c.RowChangeReason
ORDER BY c.CustomerID, c.RowStartDate;

-- High value customers

SELECT TOP 20
    c.FirstName + ' ' + c.LastName as CustomerName,
    c.CustomerCountry,
    c.CustomerCity,
    COUNT(DISTINCT f.InvoiceKey) as TotalOrders,
    SUM(f.Total) as TotalSpent,
    AVG(f.Total) as AvgOrderValue
FROM FactInvoice f
INNER JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.RowIsCurrent = 1
GROUP BY c.CustomerKey, c.FirstName, c.LastName, c.CustomerCountry, c.CustomerCity
ORDER BY TotalSpent DESC;

-- artist album track 

SELECT 
    art.ArtistName,
    alb.AlbumName,
    t.TrackName,
    g.GenreName,
    COUNT(f.InvoiceLineKey) as TimesSold,
    SUM(f.Quantity) as TotalQuantity,
    SUM(f.Total) as Revenue
FROM FactInvoice f
INNER JOIN DimTrack t ON f.TrackKey = t.TrackKey
INNER JOIN DimAlbum alb ON t.AlbumKey = alb.AlbumKey
INNER JOIN DimArtist art ON f.ArtistKey = art.ArtistKey
INNER JOIN DimGenre g ON t.GenreKey = g.GenreKey
WHERE art.RowIsCurrent = 1
GROUP BY art.ArtistName, alb.AlbumName, t.TrackName, g.GenreName
ORDER BY Revenue DESC;