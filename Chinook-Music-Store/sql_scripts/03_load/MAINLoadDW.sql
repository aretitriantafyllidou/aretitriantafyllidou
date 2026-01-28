use ChinookDW

-- Only for the first load
DELETE FROM FactInvoice;
DELETE FROM DimArtist;
DELETE FROM DimCustomer;
DELETE FROM DimTrack;
DELETE FROM DimAlbum;
DELETE FROM DimMediaType;
DELETE FROM DimGenre;


-- 1
INSERT INTO DimArtist (ArtistID, ArtistName)
SELECT 
ArtistID, ArtistName
FROM 
 ChinookStaging.dbo.Artist;

-- 2
INSERT INTO DimAlbum (AlbumID, AlbumName, ArtistKey)
SELECT 
AlbumID, AlbumName, ArtistId
FROM 
 ChinookStaging.dbo.Album;

 -- 3
INSERT INTO DimMediaType (MediaTypeID, MediaTypeName)
SELECT 
MediaTypeID, MediaTypeName
FROM 
 ChinookStaging.dbo.MediaType;

 -- 4
INSERT INTO DimGenre (GenreId, GenreName)
SELECT 
GenreID, GenreName
FROM 
 ChinookStaging.dbo.Genre;

-- 5
INSERT INTO DimCustomer ( CustomerID, Company, FirstName, LastName, CustomerCity, CustomerPostalCode,
CustomerCountry)
SELECT 
     CustomerID, Company, FirstName, LastName, City,
	PostalCode, Country
FROM 
    ChinookStaging.dbo.Customer;

-- 6
INSERT INTO DimTrack ( TrackID, TrackName, AlbumId, MediaTypedid,
GenreId, UnitPrice)
SELECT 
    TrackId, TrackName, a.AlbumId, m.MediaTypeId, g.GenreId, UnitPrice
FROM 
    ChinookStaging.dbo.Track as t
INNER JOIN ChinookDW.dbo.DimAlbum AS a
    ON a.AlbumId = t.AlbumId
INNER JOIN ChinookDW.dbo.DimMediaType AS m
    ON m.MediaTypeId = t.MediaTypeId
INNER JOIN ChinookDW.dbo.DimGenre AS g
    ON g.GenreId = t.GenreId;

-- 7
INSERT INTO FactInvoice (CustomerKey, TrackKey, ArtistKey, InvoiceKey, InvoiceLineKey, InvoiceDateKey, Total, UnitPrice, Quantity)
SELECT 
    c.CustomerKey, 
    t.TrackKey, 
    a.ArtistKey,  
    i.InvoiceID, 
    i.InvoiceLineid, 
    CAST(FORMAT(i.InvoiceDate,'yyyyMMdd') AS INT) AS InvoiceDateKey,
    i.Total, 
    i.UnitPrice, 
    i.Quantity
FROM ChinookStaging.dbo.InvoiceDetails i
INNER JOIN ChinookDW.dbo.DimCustomer c ON i.CustomerID = c.CustomerID
INNER JOIN ChinookDW.dbo.DimTrack t ON i.TrackID = t.TrackID
INNER JOIN ChinookDW.dbo.DimArtist a ON i.ArtistId = a.ArtistID;  

SELECT * FROM FactInvoice;
