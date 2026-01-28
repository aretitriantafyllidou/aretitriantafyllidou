
CREATE DATABASE ChinookStaging
GO

USE ChinookStaging
GO

DROP TABLE IF EXISTS ChinookStaging.dbo.[Artist];
DROP TABLE IF EXISTS ChinookStaging.dbo.[Customer];
DROP TABLE IF EXISTS ChinookStaging.dbo.track;
DROP TABLE IF EXISTS ChinookStaging.dbo.Invoice;
DROP TABLE IF EXISTS ChinookStaging.dbo.DimDate;


--1. get data FROM Artist
--  ArtistID,   Name


SELECT ArtistID, Chinook.[dbo].Artist.Name as ArtistName
INTO ChinookStaging.dbo.[Artist]
FROM Chinook.[dbo].[Artist]


--2 get FROM Customer
--Customer
-- CustomerID, Company, FirstName, LastName, City, PostalCode, Country

SELECT  CustomerID, Company, FirstName, LastName, City, PostalCode, Country
INTO ChinookStaging.dbo.Customer
FROM Chinook.[dbo].Customer

--3  get FROM Track
 -- TrackID, Name, AlmumID, CompanyName, CategoryName

SELECT  TrackId, Chinook.[dbo].Track.Name as TrackName  , Chinook.[dbo].album.AlbumId, Chinook.[dbo].mediaType.MediaTypeId,
Chinook.[dbo].Genre.GenreId, UnitPrice
INTO ChinookStaging.dbo.Track
FROM Chinook.[dbo].Track
INNER JOIN Chinook.[dbo].Album
    ON Chinook.[dbo].Track.Albumid = Chinook.[dbo].Album.AlbumId
INNER JOIN Chinook.[dbo].MediaType
    ON Chinook.dbo.Track.MediaTypeid = Chinook.[dbo].MediaType.MediaTypeId
INNER JOIN Chinook.[dbo].Genre
    ON Chinook.[dbo].Track.Genreid = Chinook.[dbo].Genre.GenreId


--4  get FROM Invoice
-- InvoiceID,  CustomerId(join from customers), InvoiceDate, Billing-adress, city, state, country, postal code-, Total
--Get from InvoiceLine
--InvoiceLineID,  TrackID(Join from track), InvoiceID(join from invoice), UnitPrice, Quantity

SELECT  
     Chinook.[dbo].Invoice.InvoiceID, 
     InvoiceLineid, 
     Chinook.[dbo].Track.Trackid,
     Chinook.[dbo].Invoice.CustomerId, 
     InvoiceDate, 
     BillingAddress, 
     BillingCity, 
     BillingCountry,
     BillingState, 
     BillingPostalCode, 
     Total, 
     Chinook.[dbo].InvoiceLine.UnitPrice, 
     Quantity,
     CAST(FORMAT(InvoiceDate,'yyyyMMdd') AS INT) AS InvoiceDateKey
INTO ChinookStaging.dbo.InvoiceDetails
FROM Chinook.[dbo].Invoice
INNER JOIN Chinook.[dbo].[InvoiceLine]
    ON Chinook.[dbo].Invoice.InvoiceId= Chinook.[dbo].InvoiceLine.InvoiceId 
INNER JOIN Chinook.[dbo].Track
    ON chinook.[dbo].InvoiceLine.Trackid= Chinook.[dbo].Track.Trackid
INNER JOIN Chinook.[dbo].Customer
    ON chinook.[dbo].Invoice.CustomerID=chinook.[dbo].Customer.Customerid;
