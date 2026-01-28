use ChinookDD

-- Only for the first load
DELETE FROM FactInvoice;
DELETE FROM DimArtist;
DELETE FROM DimCustomer;
DELETE FROM DimTrack;


-- 1
INSERT INTO DimArtist (ArtistID, ArtistName)
SELECT 
ArtistID, ArtistName
FROM 
 ChinookStage.dbo.Artist;

-- 2
INSERT INTO DimCustomer ( CustomerID, Company, FirstName, LastName, CustomerCity, CustomerPostalCode,
CustomerCountry)
SELECT 
     CustomerID, Company, FirstName, LastName, City,
	PostalCode, Country
FROM 
    ChinookStage.dbo.Customer;

-- 3
INSERT INTO DimTrack ( TrackID, TrackName, AlbumId, MediaTypedid,
GenreId, UnitPrice)
SELECT 
    TrackId, TrackName, AlbumId, MediaTypeId, GenreId, UnitPrice
FROM 
    ChinookStage.dbo.Track;

-- 4
INSERT INTO FactInvoice (
   CustomerKey,  TrackKey, InvoiceKey, InvoiceLineKey, InvoiceDateKey,
    Total, UnitPrice, Quantity
)
SELECT 
    CustomerKey,TrackKey, InvoiceID, InvoiceLineid, 
	CAST(FORMAT(InvoiceDate,'yyyyMMdd') AS INT) AS InvoiceDateKey ,
    Total, i.UnitPrice, Quantity
FROM 
    ChinookStage.dbo.InvoiceDetails AS i
INNER JOIN ChinookD.dbo.DimCustomer AS c
    ON c.CustomerID = i.CustomerID
INNER JOIN ChinookD.dbo.DimTrack AS t
    ON t.TrackID = i.TrackID;

-- Display the loaded data from FactInvoice
SELECT * FROM FactInvoice;
