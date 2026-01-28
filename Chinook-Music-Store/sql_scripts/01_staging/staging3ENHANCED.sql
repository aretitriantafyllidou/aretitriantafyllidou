CREATE DATABASE ChinookStaging
GO

USE ChinookStaging
GO

DROP TABLE IF EXISTS ChinookStaging.dbo.[Artist];
DROP TABLE IF EXISTS ChinookStaging.dbo.[Customer];
DROP TABLE IF EXISTS ChinookStaging.dbo.track;
DROP TABLE IF EXISTS ChinookStaging.dbo.Invoice;
DROP TABLE IF EXISTS ChinookStaging.dbo.DimDate;
DROP TABLE IF EXISTS ChinookStaging.dbo.Album;
DROP TABLE IF EXISTS ChinookStaging.dbo.Genre;
DROP TABLE IF EXISTS ChinookStaging.dbo.MediaType;


--1. get data FROM Artist
--  ArtistID,   Name


SELECT ArtistID, Chinook.[dbo].Artist.Name as ArtistName
INTO ChinookStaging.dbo.[Artist]
FROM Chinook.[dbo].[Artist]

--2. get data FROM Album
--  AlbumID,   Title, ArtistId

SELECT AlbumID, Chinook.[dbo].Album.Title as AlbumName, Chinook.[dbo].Album.ArtistId
INTO ChinookStaging.dbo.[Album]
FROM Chinook.[dbo].[Album]
INNER JOIN Chinook.[dbo].Artist
    ON Chinook.[dbo].Artist.ArtistId = Chinook.[dbo].Album.ArtistId

--3. get data FROM Genre
--  GenreID,   Name

SELECT GenreID, Chinook.[dbo].Genre.Name as GenreName
INTO ChinookStaging.dbo.[Genre]
FROM Chinook.[dbo].[Genre]

--4. get data FROM MediaType
--  GenreID,   Name


SELECT MediaTypeID, Chinook.[dbo].MediaType.Name as MediaTypeName
INTO ChinookStaging.dbo.[MediaType]
FROM Chinook.[dbo].[MediaType]



--5 get FROM Customer
--Customer
-- CustomerID, Company, FirstName, LastName, City, PostalCode, Country

SELECT  CustomerID, Company, FirstName, LastName, City, PostalCode, Country
INTO ChinookStaging.dbo.Customer
FROM Chinook.[dbo].Customer

--6  get FROM Track
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


--7  get FROM Invoice
-- InvoiceID,  CustomerId(join from customers), InvoiceDate, Billing-adress, city, state, country, postal code-, Total
--Get from InvoiceLine
--InvoiceLineID,  TrackID(Join from track), InvoiceID(join from invoice), UnitPrice, Quantity

SELECT  
    i.InvoiceID, 
    il.InvoiceLineid, 
    t.TrackId,
    t.AlbumId, 
    a.ArtistId, 
    i.CustomerId, 
    i.InvoiceDate, 
    i.BillingAddress, 
    i.BillingCity, 
    i.BillingCountry,
    i.BillingState, 
    i.BillingPostalCode, 
    i.Total, 
    il.UnitPrice, 
    il.Quantity,
    CAST(FORMAT(i.InvoiceDate,'yyyyMMdd') AS INT) AS InvoiceDateKey
INTO ChinookStaging.dbo.InvoiceDetails
FROM Chinook.[dbo].[Invoice] i
INNER JOIN Chinook.[dbo].[InvoiceLine] il
    ON i.InvoiceId = il.InvoiceId 
INNER JOIN Chinook.[dbo].[Track] t
    ON il.Trackid = t.Trackid
INNER JOIN Chinook.[dbo].[Album] a
    ON t.AlbumId = a.AlbumId
INNER JOIN Chinook.[dbo].[Artist] art
    ON a.ArtistId = art.ArtistId
INNER JOIN Chinook.[dbo].[Customer] c
    ON i.CustomerID = c.Customerid;
