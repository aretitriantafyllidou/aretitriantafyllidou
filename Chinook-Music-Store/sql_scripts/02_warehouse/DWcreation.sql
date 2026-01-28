CREATE DATABASE ChinookDW
GO

USE ChinookDW
GO

DROP TABLE IF EXISTS DimArtist;
DROP TABLE IF EXISTS DimCustomer;
DROP TABLE IF EXISTS DimTrack;
DROP TABLE IF EXISTS FactInvoice;
DROP TABLE IF EXISTS DimAlbum;
DROP TABLE IF EXISTS DimGenre;
DROP TABLE IF EXISTS DimMediaType;

---- Artist dimension will need to include:
CREATE TABLE DimArtist (
	ArtistKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ArtistID INT NOT NULL,
    ArtistName VARCHAR(120) NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2007-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

CREATE TABLE DimAlbum (
	AlbumKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    AlbumID INT NOT NULL,
    AlbumName VARCHAR(120) NULL,
	ArtistKey INT NOT NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2007-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
	FOREIGN KEY (ArtistKey) REFERENCES DimArtist(ArtistKey)
);

CREATE TABLE DimGenre (
	GenreKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    GenreId INT NOT NULL,
    GenreName VARCHAR(120) NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2007-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

CREATE TABLE DimMediaType (
	MediaTypeKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    MediaTypeID INT NOT NULL,
    MediaTypeName VARCHAR(120) NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2007-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

-- DimCustomer dimension will need to include:
CREATE TABLE DimCustomer(
    CustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerID int NOT NULL, 
	Company VARCHAR(80) NULL,
    FirstName VARCHAR(40) NOT NULL,
    LastName VARCHAR(40) NOT NULL,
    CustomerCity VARCHAR(120) NOT NULL,
    CustomerPostalCode VARCHAR(120) NULL,
	CustomerCountry  VARCHAR(120) NOT NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2007-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);


-- DimTrack dimension will need to include:
CREATE TABLE DimTrack(
    TrackKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TrackID INT NOT NULL,
    TrackName VARCHAR(200) NOT NULL,
	AlbumKey INT,
	MediaTypeKey INT,
	GenreKey INT,
    AlbumId Int NOT Null,
	MediaTypedid Int not null,
	GenreId Int NOT NULL,
	UnitPrice numeric(10,2) NOT NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
	FOREIGN KEY (AlbumKey) REFERENCES DimAlbum(AlbumKey),
	FOREIGN KEY (MediaTypeKey) REFERENCES DimMediaType(MediaTypeKey),
	FOREIGN KEY (GenreKey) REFERENCES DimGenre(GenreKey)
);


--


CREATE TABLE FactInvoice(
     InvoiceKey INT NOT NULL ,
     InvoiceLineKey INT NOT NULL,
     ArtistKey INT NULL,
     TrackKey INT NOT NULL ,
     CustomerKey INT NOT NULL,
     InvoiceDateKey INT,
     Total NUMERIC (10,2) NOT NULL,
     UnitPrice NUMERIC(10,2) NOT NULL,
     Quantity SMALLINT NOT NULL,
     FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
     FOREIGN KEY (TrackKey) REFERENCES DimTrack(TrackKey),
     FOREIGN KEY (ArtistKey) REFERENCES DimArtist(ArtistKey)
);
