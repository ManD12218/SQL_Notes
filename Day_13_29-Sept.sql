--TODO:



-- Finding Expensive queries
-- Refer- https://techsapphire.net/finding-expensive-queries-in-sql-server-and-performance-optimization



-- JSON
-- Check if a string is valid JSON
SELECT ISJSON('{"name":"John", "age":30}') AS IsValidJson;
-- Output: 1

-- Extract a value from JSON by passing a key
SELECT JSON_VALUE('{"name":"Jane", "city":"New York"}', '$.city') AS City;
-- Output: New York

-- Parse a JSON array into a table
SELECT *
FROM OPENJSON('[{"id":1, "name":"Alice"}, {"id":2, "name":"Bob"}]')
WITH (
    id INT '$.id',
    name NVARCHAR(100) '$.name'
);

-- Refer - -- https://learn.microsoft.com/en-us/sql/relational-databases/json/json-data-sql-server?view=sql-serve…
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/json-value-transact-sql?view=sql-server-ver17
-- https://www.geeksforgeeks.org/sql/working-with-json-in-sql/

-- Modify JSON
DECLARE @json NVARCHAR(MAX);
 
SET @json = '{"info": {"address": [{"town": "Belgrade"}, {"town": "Paris"}, {"town":"Madrid"}]}}';
SET @json = JSON_MODIFY(@json, '$.info.address[1].town', 'London');
 
SELECT modifiedJson = @json;
 
SET @json = JSON_MODIFY(@json, '$.info.address[0].town', 'Bengaluru');
SELECT modifiedJson = @json;



-- XML
-- Much cleaner and easier to under the code. The demographics Data is stored in a CTE, which is further used.

;WITH ParsedDemographics AS
(
    SELECT 
        p.BusinessEntityID,
        CAST(p.Demographics AS XML) AS DemographicsXml
    FROM Person.Person p
)
, FlattenedSurvey AS
(
    SELECT 
        BusinessEntityID,
        DemographicsXml.value('
            declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";

            (/IndividualSurvey/TotalPurchaseYTD/text())[1]', 'decimal(18,2)') AS TotalPurchaseYTD,
        DemographicsXml.value('
            declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";

            (/IndividualSurvey/AnnualIncome/text())[1]', 'varchar(50)') AS AnnualIncome,
        DemographicsXml.value('

            declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";

            (/IndividualSurvey/Education/text())[1]', 'varchar(50)') AS Education,
 
        DemographicsXml.value('

            declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";

            (/IndividualSurvey/Occupation/text())[1]', 'varchar(50)') AS Occupation,
 
        DemographicsXml.value('

            declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";

            (/IndividualSurvey/HomeOwnerFlag/text())[1]', 'varchar(5)') AS HomeOwnerFlag,
 
        DemographicsXml.value('

            declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";

            (/IndividualSurvey/NumberChildrenAtHome/text())[1]', 'int') AS NumberChildrenAtHome,
 
        DemographicsXml.value('

            declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";

            (/IndividualSurvey/NumberCarsOwned/text())[1]', 'int') AS NumberCarsOwned

    FROM ParsedDemographics
)
SELECT *
FROM FlattenedSurvey
WHERE TotalPurchaseYTD BETWEEN 100 AND 1000;
 

 
-- GENERATE JSON from existing Table
-- Microservices often communicate using RESTful APIs, which commonly return and accept data in JSON format.

USE AdventureWorks2022
GO

SELECT soh.SalesOrderNumber, soh.OrderDate, soh.TotalDue
    , (SELECT sod.ProductID, sod.OrderQty
    FROM sales.SalesOrderDetail AS sod
    WHERE sod.SalesOrderID = soh.SalesOrderID FOR JSON PATH) AS Items
FROM sales.SalesOrderHeader AS soh
FOR JSON PATH, ROOT('OrderDetails');
 
SELECT * FROM Sales.Customer FOR JSON AUTO;
SELECT * FROM Sales.Customer FOR JSON AUTO, ROOT ('CustomerInfo');


-- Calling RESTApi 
-- Refer - https://priyarajtt.medium.com/ways-to-use-rest-api-output-of-json-data-and-import-in-sql-server-fcda04914ead
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO

Declare @WinHttpObject as Int;
Declare @ResponseJsonText as Varchar(8000);
 
Exec sp_OACreate 'WinHttp.WinHttpRequest.5.1', @WinHttpObject OUT;
 
-- sp_OAMethod procedure opened an HTTP connection , here it is https://api.exchangerate-api.com/v4/latest/INR
Exec sp_OAMethod @WinHttpObject, 'open', NULL, 'get', 'https://api.exchangerate-api.com/v4/latest/INR'
Exec sp_OAMethod @WinHttpObject, 'send'
 
-- ResponseText method retrieved the response of the web server as a text.
Exec sp_OAMethod @WinHttpObject, 'responseText', @ResponseJsonText OUTPUT
 
-- sp_OADestroy procedure destroyed the created instance of the object.
Exec sp_OADestroy @WinHttpObject
 
-- checking for the validity of JSON
IF ISJSON(@ResponseJsonText)=1
 
-- Get the necessary details
BEGIN
SELECT INRRates,USDRates,GBPRates FROM OPENJSON(@ResponseJsonText)
WITH(INRRates VARCHAR(10) '$.rates.INR',USDRates VARCHAR(10) '$.rates.USD', GBPRates VARCHAR(10) '$.rates.GBP')
END


-- TRIGGERS
/*
CREATE TRIGGER trg_AfterInsert_Products
ON Products
AFTER INSERT
AS
BEGIN
    -- Log the newly inserted product into an audit table
    INSERT INTO ProductAudit (ProductID, ProductName, InsertedDate)
    SELECT ProductID, ProductName, GETDATE()
    FROM INSERTED;
END;
*/
-- Triggers are not generally recommended


-- TODO : TEMPORAL TABLES
-- REFER - https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables?view=sql-server-v…
-- REFER - https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal-table-usage-scenarios?vi…

 -- QUERY STORE
 -- Monitor performance by using the Query Store
 -- REFER - https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-ver17
 -- TODO : Waiting query


 -- Last queries executed on the database
 -- REFER : https://learn.microsoft.com/en-us/sql/relational-databases/performance/tune-performance-with-the-query-store?view=sql-server-ver17
 SELECT TOP 10 qt.query_sql_text,
    q.query_id,
    qt.query_text_id,
    p.plan_id,
    rs.last_execution_time
FROM sys.query_store_query_text AS qt
INNER JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
INNER JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
INNER JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
WHERE rs.last_execution_time > DATEADD(HOUR, -1, GETUTCDATE())
ORDER BY rs.last_execution_time DESC;