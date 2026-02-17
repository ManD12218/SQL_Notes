CREATE OR ALTER PROCEDURE uspTest
    @FN VARCHAR(100),
    @LN VARCHAR(100) = NULL -- We are providing this parameter an optional value or Default value. 
AS
BEGIN
    -- PRINT  'Hello' + ' ' + @FN + ' ' + @LN
	 PRINT CONCAT_WS(' ', 'Hello', @FN, @LN);
END;
GO;

EXEC uspTest 'MANDEEP', 'KUMAR'
EXEC uspTest 'MANDEEP' 
/* With Print as strings and default value of any of the parameters as NULL, 
the resulting string will be NULL but not when strings are concatenated
*/
EXEC uspTest @LN = 'MANDEEP', @FN = 'KUMAR'
EXEC uspTest @LN = 'MANDEEP', @FN = NULL

-- Specify Paramater direction

USE AdventureWorks2022;  
GO  
IF OBJECT_ID ( 'Production.uspGetList', 'P' ) IS NOT NULL   
    DROP PROCEDURE Production.uspGetList;  
GO  
CREATE PROCEDURE Production.uspGetList 
      @Product varchar(40)   
    , @MaxPrice money   
    , @ComparePrice money OUTPUT  
    , @ListPrice money OUT  
AS  
    SET NOCOUNT ON;  
    SELECT p.[Name] AS Product, p.ListPrice AS 'List Price'  
    FROM Production.Product AS p  
    JOIN Production.ProductSubcategory AS s   
      ON p.ProductSubcategoryID = s.ProductSubcategoryID  
    WHERE s.[Name] LIKE @Product AND p.ListPrice < @MaxPrice;  
-- Populate the output variable @ListPprice.  
SET @ListPrice = (SELECT MAX(p.ListPrice)  
        FROM Production.Product AS p  
        JOIN  Production.ProductSubcategory AS s   
          ON p.ProductSubcategoryID = s.ProductSubcategoryID  
        WHERE s.[Name] LIKE @Product AND p.ListPrice < @MaxPrice);  
-- Populate the output variable @compareprice.  
SET @ComparePrice = @MaxPrice;  
GO

DECLARE @ComparePrice money, @Cost money ;  
EXECUTE Production.uspGetList '%Bikes%', 700,   
    @ComparePrice OUT,   
    @Cost OUTPUT  
IF @Cost <= @ComparePrice   
BEGIN  
    PRINT 'These products can be purchased for less than   
    $'+RTRIM(CAST(@ComparePrice AS varchar(20)))+'.'  
END  
ELSE  
    PRINT 'The prices for all products in this category exceed   
    $'+ RTRIM(CAST(@ComparePrice AS varchar(20)))+'.';



-- TODO: Read GROUP BY ROLLUP, GROUP BY CUBE ( ), GROUP BY GROUPING SETS ( )
CREATE TABLE SalesTest (Country VARCHAR(100), Region VARCHAR(100) ,TotalSales INT(100) )
INSERT INTO dbo.SalesTest (Country, Region, TotalSales) VALUES
    ('Canada', 'Alberta', 100),
    ('Canada', 'British Columbia', 500),
    ('Canada', NULL, 600),
    ('United States', 'Montana', 100),
    ('United States', NULL, 100),
    ('Japan', NULL, 700);

select * from SalesTest
UPDATE salesTest
set Country = 'Japan'
where Country is null

CREATE TABLE SalesTestV1 (Country VARCHAR(100), Region VARCHAR(100) ,TotalSales INT )
INSERT INTO dbo.SalesTestV1 (Country, Region, TotalSales) VALUES
    ('Canada', 'Alberta', 100),
    ('Canada', 'British Columbia', 500),
    ('Canada', NULL, 600),
    ('United States', 'Montana', 100),
    ('United States', NULL, 100),
    ('Japan', NULL, 700);

INSERT INTO dbo.SalesTestV1 (Country, Region, TotalSales) VALUES
	('Japan', NULL, 300);
INSERT INTO dbo.SalesTestV1 (Country, Region, TotalSales) VALUES
	('Japan', 'Tokyo', 200);


select * from SalesTestV1
SELECT Country, Region, SUM(TotalSales) AS TotalSales
FROM SalesTestV1
GROUP BY ROLLUP (Country, Region);


-- TODO -PARTITIONING
Select * from sys.tables
Select * from sys.indexes
Select * from sys.partition_schemes