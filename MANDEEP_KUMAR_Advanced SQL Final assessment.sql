/*----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

										NAME   : MANDEEP KUMAR 
										EMP ID : 63150748

------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------*/

/* QUESTION 01 : 
Show all products names and corresponding SalesAmount, irrespective whether that product is sold or not. 
In case product is not sold, the sales amount can be shown as null.

SUGGESTED DATABASE : OLTP
*/ 

USE AdventureWorks2022
GO

-- Products with sales
SELECT pt.ProductID, pt.Name, SUM(sl.LineTotal) as SalesAmount
FROM Production.Product as pt
JOIN sales.SalesOrderDetail sl ON pt.ProductID = sl.ProductID
GROUP BY pt.ProductID, pt.Name

UNION

-- Products without sales
SELECT pt.ProductID, pt.Name, NULL as SalesAmount
FROM Production.Product as pt
WHERE pt.ProductID NOT IN (SELECT ProductID FROM sales.SalesOrderDetail);


/* QUESTION 02: 
Write a view that returns combine sales of factinternetsales and factresellersales. 
Summarize the data territorywise + yearwise + CustomerKey/ResellerKey. 
Display the data in sorted order of Year in descending order and Territory in ascending order. 
Use of multiple CTEs/Derived Tables (1 for fis and other for FRS) inside view is a mandatory. 
FIS has CustomerKEY where as FRS has ResellerKey, these are to be combined in same column by the name ClientKey. 
*/

/* SOLUTION:
PART 01. CREATE VIEW
PART 02. DISPLAY data sorted as order of Year in descending order and Territory in ascending order. 
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

-- SOLUTION PART 01 : Definition of VIEW
CREATE VIEW vw_SalesSummary AS
WITH fis_cte AS 
(
SELECT SalesTerritoryKey, YEAR(OrderDate) AS OrderYear, CustomerKey AS ClientKey, SUM(salesAmount) AS TotalSales 
FROM FactInternetSales
GROUP BY SalesTerritoryKey, YEAR(OrderDate), CustomerKey
), 
frs_cte AS (
SELECT SalesTerritoryKey, YEAR(OrderDate) AS OrderYear, ResellerKey AS ClientKey, SUM(salesAmount) AS TotalSales 
FROM FactResellerSales
GROUP BY SalesTerritoryKey, YEAR(OrderDate), ResellerKey
)

SELECT SalesTerritoryKey, OrderYear,  ClientKey, TotalSales
FROM fis_cte

UNION ALL

SELECT SalesTerritoryKey, OrderYear,  ClientKey, TotalSales
FROM frs_cte

-- SOLUTION PART 02

SELECT *
FROM vw_SalesSummary
ORDER BY OrderYear DESC, SalesTerritoryKey ASC


/* QUESTION 03: 
Show all the CurrencyKey and corresponding Currency names using which at least 1 sale is made over internet. 
Use either subquery or CTE in solution.
OR
Show all the Currency Key and corresponding Currency names which are never sold even once over internet. 
Use either subquery or CTE in solution.
*/

/* SOLUTION:
PART 01. Check if any currency salesAmount = 0 or NULL? If yes, then investigate all values for such currencyKey's
PART 02. If not then, Use a subquery to fetch all unique CurrencyKey from FIS and get Names from DimCurrency
*/

-- SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

-- SOLUTION PART 01 : Check in FIS if any currency salesAmount = 0 or NULL ? 
SELECT  min(SalesAmount) as Minimum_SalesAmount, max(SalesAmount) as Maximum_SalesAmount
FROM FactInternetSales 

SELECT * FROM FactInternetSales 
WHERE SalesAmount IS NULL

-- SOLUTION PART 02 : 
select CurrencyKey, CurrencyName
from DimCurrency as dc
where CurrencyKey IN (select distinct CurrencyKey from FactInternetSales)


/* QUESTION 04: 
Show all customer id and customer's firstname if he/she has ever purchased any of the products 
purchased by customer 11000. 
Use of subquery is mandatory in the solution. 
Use FactInternetSales and other required tables.
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO


SELECT fis.CustomerKey, dc.FirstName
FROM DimCustomer AS dc
JOIN FactInternetSales AS fis ON fis.CustomerKey=dc.CustomerKey
WHERE fis.ProductKey IN (SELECT ProductKey FROM FactInternetSales WHERE CustomerKey=11000)
GROUP BY fis.CustomerKey, dc.FirstName


/* QUESTION 05: 
Show CountryRegion name, DimReseller.ResellerName, Sum Sales in descending order. 
Show rank, dense rank, and also create 4 buckets in which Reseller to be divided. 
The sum of sales to be shown in US currency format.  This is based on Reseller Sales.
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

WITH SalesSummary AS 
(
SELECT dst.SalesTerritoryCountry
	, ds.ResellerName
	, SUM(frs.SalesAmount) AS TotalSales
FROM FactResellerSales AS frs
JOIN DimSalesTerritory AS dst ON frs.SalesTerritoryKey=dst.SalesTerritoryKey
JOIN DimReseller AS ds ON ds.ResellerKey=frs.ResellerKey
GROUP BY dst.SalesTerritoryCountry, ds.ResellerName
)

SELECT SalesTerritoryCountry
	, ResellerName
	, FORMAT(TotalSales, 'C', 'en-US') as TotalSales
	, RANK() over (PARTITION BY SalesTerritoryCountry order by TotalSales) as Ranking
	, dense_rank() over (PARTITION BY SalesTerritoryCountry order by TotalSales) as Dense_Ranking 
	, NTILE(4) OVER (ORDER BY TotalSales DESC) AS SalesBucket
from SalesSummary
Order by TotalSales ASC



/* QUESTION 06: 
Show all cities in which customer exists but there is no reseller.
OR
Show all cities where at least one customer or reseller exists.
OR
Show all cities in which both reseller and customer exists.
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

WITH CitiesWithCustomersButNoReseller AS
(
SELECT dc.GeographyKey, dg.City
FROM DimCustomer AS dc
LEFT JOIN DimGeography AS dg ON dg.GeographyKey=dc.GeographyKey
WHERE dc.GeographyKey NOT IN (SELECT GeographyKey FROM DimReseller)
)

SELECT DISTINCT city
FROM CitiesWithCustomersButNoReseller



/* QUESTION 07: 
Create an Indexed view that returns productkey, productname, sum of sales, count of records. 
The view definition shouldn't be visible using system views. 
The underlying tables shouldn't be allowed to be deleted till the time view exists. 
Show the data using view.
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

-- Create view
CREATE VIEW dbo.vw_ProductSalesSummary
WITH SCHEMABINDING, ENCRYPTION
AS
SELECT 
    dp.ProductKey,
    dp.EnglishProductName AS ProductName,
    SUM(fis.SalesAmount) AS TotalSales,
    COUNT(*) AS SalesCount
FROM dbo.DimProduct dp
JOIN dbo.FactInternetSales fis ON dp.ProductKey = fis.ProductKey
GROUP BY dp.ProductKey, dp.EnglishProductName;
GO

-- Create an index on the view
CREATE UNIQUE CLUSTERED INDEX IX_vw_ProductSalesSummary
ON dbo.vw_ProductSalesSummary(ProductKey)

-- CHECK SCHEMABINDING 
SELECT object_id, DEFINITION, is_schema_bound FROM sys.sql_modules
WHERE object_id = OBJECT_ID('dbo.vw_ProductSalesSummary')

-- CHECK ENCRYPTION
DROP TABLE DimProduct

-- Show Data from VIEW with and without Index
SELECT * FROM dbo.vw_ProductSalesSummary
SELECT ProductKey FROM dbo.vw_ProductSalesSummary



/* QUESTION 08: 
There is slowness when data is queried with filter on firstname of dimcustomer table. 
Provide the solution by which slowness will be reduced.
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

-- Check slowness
SET STATISTICS TIME ON 
SELECT FirstName, LastName FROM DimCustomer WHERE FirstName = 'Wyatt'
SET STATISTICS TIME OFF
--  elapsed time = 45 ms.

-- RECOMMENDED SOLUTION : Create a Nonclustered Index on FirstName
CREATE NONCLUSTERED INDEX IX_DimCustomer_FirstName
ON dbo.DimCustomer (FirstName);

-- Check after NC Index 
SET STATISTICS TIME ON 
SELECT FirstName, LastName FROM DimCustomer WHERE FirstName = 'Wyatt'
SET STATISTICS TIME OFF
-- elapsed time = 9 ms.


/* QUESTION 09: 
a. Build queries to show use of  OPENJSON, JSON_VALUE, ISJSON
b. Write query to show every CustomerKey, customer name, and then all related orderid wise sum sales 
in JSON format. Please note CustomerKey and CustomerName should be shown normally i.e. not in json 
format, but related orderid and sum of sales should be shown in a single column using JSON.
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

-- PART A : Declare a JSON and use OPENJSON() to Parse JSON into rows and columns
DECLARE @json NVARCHAR(MAX) = '
[
    {"Product":"Laptop","Price":1200},
    {"Product":"Tablet","Price":800},
    {"Product":"Phone","Price":600}
]'
SELECT * FROM OPENJSON(@json)
WITH (
    Product NVARCHAR(100),
    Price INT
);

-- PART A : Use JSON_VALUE() to Extract a scalar value from JSON with only one object
DECLARE @json01 NVARCHAR(MAX) = '{"Product":"Laptop","Price":1200}'
SELECT 
    JSON_VALUE(@json01, '$.Product') AS ProductName,
    JSON_VALUE(@json01, '$.Price') AS ProductPrice;

-- PART A : Use ISJSON() to Check if a string is valid JSON or not. 
DECLARE @json02 NVARCHAR(MAX) = '{"Product":"Laptop","Price":1200}';
SELECT ISJSON(@json02) AS IsValidJson;

-- PART B : 
SELECT dc.CustomerKey, dc.FirstName, dc.LastName
    , (
		SELECT 
            fis.SalesOrderNumber AS OrderID,
            SUM(fis.SalesAmount) AS TotalSales
        FROM FactInternetSales AS fis
        WHERE fis.CustomerKey = dc.CustomerKey
        GROUP BY SalesOrderNumber
		FOR JSON AUTO 
		) AS Items
FROM DimCustomer as dc
WHERE EXISTS (SELECT 1 FROM FactInternetSales AS fis WHERE fis.CustomerKey=dc.CustomerKey);



/* QUESTION 10: 
Create a Temporal table named CustDemo with fields CustID, FN, Sales. 
Add 4 records to it - let the CustIDs be 1, 2, 3, 4 with FN as a, B, C, D; 
and Sales as 100 for all. Display the data. 
Write additional code to
1. Modify the sales to 200 for custid 2.
2. Write queries to show records from CustDemoa and history table.
3. Change the same record to make the sales 300.
4. Write queries to show records from CustDemoa and history table.
5. Display the record  using CustDemo (not explicitely history table) where it will show the 
Sales value of 200. i.e. in turn SQL will fetch data from history table.
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

-- CREATE CustDemo table as Temporal Table
CREATE TABLE CustDemo
(
    CustID INT NOT NULL PRIMARY KEY,
    FN NVARCHAR(50),
    Sales INT,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CustDemoHistory));

-- INSERT 4 records
INSERT INTO CustDemo (CustID, FN, Sales)
VALUES 
(1, 'A', 100),
(2, 'B', 100),
(3, 'C', 100),
(4, 'D', 100);

-- Display Data
SELECT * FROM CustDemo

-- 01: Modify Sales to 200 for CustID = 2
UPDATE CustDemo
SET Sales = 200
WHERE CustID = 2;

-- 02: Show records from CustDemo and its history table
-- Current Table
SELECT * FROM CustDemo;

-- Historical data
SELECT * FROM CustDemoHistory;

-- 03: Modify Sales to 300 for CustID = 2
UPDATE CustDemo
SET Sales = 300
WHERE CustID = 2;

-- 04: Show records again from CustDemo and history
-- Current Table
SELECT * FROM CustDemo;

-- Historical data
SELECT * FROM CustDemoHistory;

-- 05: Display the record using CustDemo where Sales = 200 for all Times
SELECT *
FROM CustDemo
FOR SYSTEM_TIME ALL
WHERE CustID = 2 AND Sales = 200;


/* QUESTION 11: 
Create Student, Subject, and StudentMarks tables in datawarehouse database using given scripts on sheet 
Setup Database. Please ensure that proper code formating and transaction handling is done...
also exception handling (both in stored procedure and the code that tets the stored proc) is done. 
These too carries the marks.

The business logic to be implemented in following order.
1. Create a stored procedure (uspAddStudentMarks) to add new records in StudentMarks table. 
Stored procedure will accept parameters to store the values in StudentMarks table.
2. Increase the count of SubjectMarksReceived by 1 in table Student.
3. The stored procedure should validate that the provided studentid exists in Student table. 
If not, it should give the message ""Student id does not exist.".
Do this validation using user defined functions.
4. The stored procedure should validate that the provided Subjectid exists in Subject table. 
If not, it should give the message ""Subject id does not exist."". 
Do this validation using user defined functions.
If any of the transaction(s) fails, full transaction should be rolled back. 
It should be either save all or none. i.e. use transactions and try catch as appropriate.

1. Insert couple of valid records in StudentMarks table to ensure that with all valid data it works smoothly.
2. Next, provide insert statements (as given below) to trigger each of the valiation and get error message back.
a. Send NULL value for Marks and valid values for all other fields.
b. Send NULL value for SubjectID and valid values for all other fields.
c. Send NULL value for StudentID and valid values for all other fields.
d. Send -5 (minus five) for SubjectMarks and valid values for all other values.
e. For any one of the students try to add more than 2 records in StudentMarks table. 
SQL Server should throw exception as there is constraint of [SubjectMarksReceived]  < 3."
*/

--SUGGESTED DATABASE : DW
USE AdventureWorksDW2022
GO

BEGIN TRY
	BEGIN TRANSACTION
	--Code to create Subject table and add records in it.
		IF OBJECT_ID('StudentMarks') > 0 DROP Table StudentMarks;
		IF OBJECT_ID('Subject') > 0 DROP Table Subject;
		IF OBJECT_ID('Student') > 0 DROP Table Student;
		

		CREATE TABLE [dbo].[Subject](
			[SubjectID] [int] NOT NULL PRIMARY KEY,
			[SubjectName] [varchar](50) NOT NULL,
			[Status] [varchar](50) NULL CHECK (([Status]='Non-Active' OR [Status]='Active')),
			[StudentCount] [int] NULL DEFAULT 0,
		);
		
		INSERT INTO Subject Values (1, 'English', 'Active', 0);
		INSERT INTO Subject Values (2, 'Science', 'Active', 0);
		
		SELECT * FROM Subject;
		
		--Code to create Student Table and add records in it
		CREATE TABLE [dbo].[Student](
			[StudentID] [int] NOT NULL PRIMARY KEY,
			[FirstName] [varchar](50) NOT NULL,
			[SubjectMarksReceived] INT CONSTRAINT CHK_SubjectMarksReceived CHECK ([SubjectMarksReceived] < 3),
			--[Status] [varchar](50) NOT NULL CHECK (([Status]='Non-Active' OR [Status]='Active')),
			--[SchoolID] [int] NOT NULL FOREIGN KEY([deptID]) REFERENCES [dbo].[Dept] ([deptID])
		);

		INSERT INTO Student Values (1, 'Madhuri', 0);
		INSERT INTO Student Values (2, 'Amitabh', 0);
		INSERT INTO Student Values (3, 'Varun', 0);
		INSERT INTO Student Values (4, 'Katrina', 0);

		SELECT * FROM Student;

		--Code to create StudentMarks Table
		
		CREATE TABLE [dbo].[StudentMarks](
			[StudentID] [int] NOT NULL FOREIGN KEY([StudentID]) REFERENCES [dbo].[Student] ([StudentID]),
			[SubjectID] [int] NOT NULL FOREIGN KEY([SubjectID]) REFERENCES [dbo].[Subject] ([SubjectID]),
			[Marks] [int] NOT NULL CHECK ([Marks] >= 0 AND [Marks] <= 100),
			[Status] [varchar](50) NOT NULL CHECK (([Status]='Pass' OR [Status]='Fail')),
		);

		SELECT * FROM StudentMarks;
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT error_message()
END CATCH;
GO

-- UDF to check if StudentID exists
CREATE or ALTER FUNCTION dbo.udf_StudentExists (@StudentID INT)
RETURNS BIT
AS
BEGIN
    RETURN (
        SELECT CASE WHEN EXISTS (
            SELECT 1 FROM dbo.Student WHERE StudentID = @StudentID
        ) THEN 1 ELSE 0 END
    );
END;
GO

-- UDF to check if SubjectID exists
CREATE OR ALTER FUNCTION dbo.udf_SubjectExists (@SubjectID INT)
RETURNS BIT
AS
BEGIN
    RETURN (
        SELECT CASE WHEN EXISTS (
            SELECT 1 FROM dbo.Subject WHERE SubjectID = @SubjectID
        ) THEN 1 ELSE 0 END
    );
END;
GO
-- Creating SP
CREATE OR ALTER PROCEDURE dbo.uspAddStudentMarks
    @StudentID INT,
    @SubjectID INT,
    @Marks INT,
    @Status VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate Student
        IF dbo.udf_StudentExists(@StudentID) = 0
        BEGIN
            RAISERROR('Student id does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate Subject
        IF dbo.udf_SubjectExists(@SubjectID) = 0
        BEGIN
            RAISERROR('Subject id does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insert into StudentMarks
        INSERT INTO dbo.StudentMarks (StudentID, SubjectID, Marks, Status)
        VALUES (@StudentID, @SubjectID, @Marks, @Status);

        -- Update SubjectMarksReceived in Student
        UPDATE dbo.Student
        SET SubjectMarksReceived = SubjectMarksReceived + 1
        WHERE StudentID = @StudentID;

        COMMIT TRANSACTION;
        PRINT 'Student marks added successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


--1. .
--2. Next, provide insert statements (as given below) to trigger each of the valiation and get error message back.
--a. Send NULL value for Marks and valid values for all other fields.
--b. Send NULL value for SubjectID and valid values for all other fields.
--c. Send NULL value for StudentID and valid values for all other fields.
--d. Send -5 (minus five) for SubjectMarks and valid values for all other values.
--e. For any one of the students try to add more than 2 records in StudentMarks table. 
--SQL Server should throw exception as there is constraint of [SubjectMarksReceived]  < 3."

-- 1. Insert couple of valid records in StudentMarks table to ensure that with all valid data it works smoothly
EXEC uspAddStudentMarks @StudentID = 1, @SubjectID = 1, @Marks = 85, @Status='Pass'
EXEC uspAddStudentMarks @StudentID = 1, @SubjectID = 2, @Marks = 90, @Status='Pass'

SELECT * FROM Student
SELECT * FROM Subject
SELECT * FROM StudentMarks

-- 2.A - Send NULL value for Marks and valid values for all other fields
EXEC uspAddStudentMarks @StudentID = 1, @SubjectID = 1, @Marks = NULL, @Status='Pass';

-- 2.B - Send NULL value for SubjectID and valid values for all other fields
EXEC uspAddStudentMarks @StudentID = 1, @SubjectID = NULL, @Marks = 88, @Status='Pass';

-- 2.C - Send NULL value for StudentID and valid values for all other fields
EXEC uspAddStudentMarks @StudentID = NULL, @SubjectID = 1, @Marks = 88, @Status='Pass';

-- 2.D - Send -5 (minus five) for SubjectMarks and valid values for all other values.
EXEC uspAddStudentMarks @StudentID = 1, @SubjectID = 1, @Marks = -5, @Status='Fail';

-- 2.E - For any one of the students try to add more than 2 records in StudentMarks table. 
EXEC uspAddStudentMarks @StudentID = 1, @SubjectID = 1, @Marks = 82, @Status='Pass'


