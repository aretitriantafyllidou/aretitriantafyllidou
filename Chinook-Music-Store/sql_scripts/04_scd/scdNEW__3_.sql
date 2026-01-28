USE [ChinookStaging]
GO

TRUNCATE TABLE [ChinookStaging].[dbo].[Customer];

INSERT INTO [ChinookStaging].[dbo].[Customer]
    (CustomerID, FirstName, LastName, Company, Country, PostalCode)
SELECT 
    CustomerID, FirstName, LastName, Company, Country, PostalCode
FROM [Chinook].[dbo].[Customer];

USE [ChinookStaging]
GO


DROP TABLE IF EXISTS [ChinookStaging].[dbo].Staging_DimCustomer;

-- Create the staging table
CREATE TABLE [ChinookStaging].[dbo].Staging_DimCustomer (
    CustomerKey INT IDENTITY(1,1) NOT NULL,
    CustomerID INT NOT NULL,
    FirstName VARCHAR(40) NOT NULL,
    LastName VARCHAR(40) NOT NULL,
    Company VARCHAR(80) NULL,
    Country VARCHAR(40) NOT NULL,
    City VARCHAR(40) NOT NULL,
    PostalCode VARCHAR(20) NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

INSERT INTO [ChinookStaging].[dbo].Staging_DimCustomer (
    CustomerID, FirstName, LastName, Company, Country, City, PostalCode
)
SELECT
    CustomerID, FirstName, LastName, Company,
    Country,
    City,
    ISNULL(PostalCode, 'N/A')
FROM [Chinook].[dbo].[Customer];
ALTER TABLE [ChinookDW].[dbo].DimCustomer
ALTER COLUMN CustomerCity VARCHAR(40);


-- Απενεργοποίηση ξένης κλειδωμένης σχέσης προσωρινά


ALTER TABLE ChinookDW.dbo.FactInvoice
DROP CONSTRAINT FK__FactInvoi__Custo__44FF419A;


--
DECLARE @etldate DATE = '1998-05-07';

INSERT INTO ChinookDW.dbo.DimCustomer (
    CustomerID, FirstName, LastName, Company, CustomerCountry, CustomerCity, CustomerPostalCode, RowStartDate, RowChangeReason
)
SELECT 
    CustomerID, FirstName, LastName, Company, Country, City, PostalCode, @etldate, ActionName
FROM (
    MERGE ChinookDW.dbo.DimCustomer AS target
    USING ChinookStaging.dbo.Staging_DimCustomer AS source
    ON target.[CustomerID] = source.[CustomerID]
    WHEN MATCHED AND source.City <> target.CustomerCity AND target.RowIsCurrent = 1 THEN
        UPDATE SET 
            target.RowIsCurrent = 0, 
            target.RowEndDate = DATEADD(day, -1, @etldate), 
            target.RowChangeReason = 'UPDATED NOT CURRENT'
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            CustomerID, FirstName, LastName, Company, CustomerCountry, CustomerCity, CustomerPostalCode, RowStartDate, RowChangeReason
        )
        VALUES (
            source.CustomerID, source.FirstName, source.LastName, source.Company, 
            source.Country, source.City, source.PostalCode, @etldate, 'NEW RECORD'
        )
    WHEN NOT MATCHED BY SOURCE AND target.RowIsCurrent = 1 THEN
        UPDATE SET 
            target.RowEndDate = DATEADD(day, -1, @etldate), 
            target.RowIsCurrent = 0, 
            target.RowChangeReason = 'SOFT DELETE'
    OUTPUT 
        source.CustomerID, source.FirstName, source.LastName, source.Company, 
        source.Country, source.City, source.PostalCode, $action AS ActionName
) AS Mrg
WHERE Mrg.ActionName = 'UPDATE'
AND CustomerID IS NOT NULL;

-- Επαναφορά της ξένης κλειδωμένης σχέσης
ALTER TABLE ChinookDW.dbo.FactInvoice
ADD CONSTRAINT FK__FactInvoi__Custo__44FF419A FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey);
