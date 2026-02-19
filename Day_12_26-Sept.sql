
-- INDEXES
-- What they do - makes retrieval of data faster
-- On which columns shall we create indexes- Indexes are generally created on columns most frequently searched for. 
-- For e.g- FirstName, LastName but not Address. We can create a seaparate index on each column but that would 
-- take extra storage and wont be a optmised way. THerefore it is recommended to only create indexes on columns most
-- frequently searched for

-- NOTE: this is how you create a copy of a table with name changes
use AdventureWorksDW2022
SELECT * FROM DimCustomer
Select * INTO Cust FROM DimCustomer
select * from Cust

SELECT * from DimCustomer WHERE FirstName='Adam'
SELECT * from Cust WHERE FirstName='Adam'
-- For the above two query plan- it shows 50% each but the top query uses a clustered index and the belwo query uses Table Scan. 
-- For now we can consider these two scans to be the same


CREATE INDEX idx_cust ON DimCustomer (FirstName)
-- For the above two query plan after the index creation- it shows18% for the table with Index and 82% without one, 

SELECT * from DimCustomer WHERE LastName = 'Adam'
SELECT * from Cust WHERE LastName = 'Adam'
-- We can see that there is an index for the DimCustomer table but it is on the column- firstName and not the LastName 
-- which is being wqueried in the above queries and therefore of no use

CREATE INDEX idx_cust_LN ON DimCustomer (LastName)

SELECT * from DimCustomer WHERE LastName IN ('Adam','Alexander','Allen')
SELECT * from Cust WHERE LastName IN ('Adam','Alexander','Allen')
-- If you note for the above query the Index dont make much diff since the no of keyqords are more and it wont 
-- make much diff because now time cost will m=be more in both index and the table

SELECT * from DimCustomer WHERE LastName = 'Allen'
SELECT * from Cust WHERE LastName = 'Allen'

SELECT * from DimCustomer WHERE FirstName='Adam' AND LastName = 'Allen'
SELECT * from Cust WHERE FirstName='Adam' AND LastName = 'Allen'
-- see the diff of timne cost in the above queries

SELECT * 
from DimCustomer WHERE FirstName='Adam' AND LastName = 'Allen'
SELECT FirstName, LastName
from DimCustomer WHERE FirstName='Adam' AND LastName = 'Allen'
/* For the above two queries from the SAME TABLE the 2nd one is faster then the first one, why? 
since the 2nd one doesnot have to find the select columns since they are already mentioned in the where filter. 
whereas the first query has to bring all rows after filter
*/

SELECT LastName, MiddleName
from DimCustomer WHERE LastName = 'Allen'
SELECT LastName, MiddleName
from Cust WHERE LastName = 'Allen'
-- 

-- COVERING INDEX
CREATE INDEX idx_LN_MN  ON DimCustomer (LastName) INCLUDE (MiddleName)
-- There are two ways to create indexes f=with multiple columns but with every update 
-- on the main table the indexes also needs to get updated which is an overhead cost for the 
-- server. For this we can use INCLUDE as coveriuing index where the column although is added to the index but will not get updated when the main table 
-- is updated. This saves us the extra cost although the column included as INCLUDE will not get updated with the table. 

SELECT LastName, MiddleName
from DimCustomer WHERE LastName = 'Allen'
SELECT LastName, MiddleName
from Cust WHERE LastName = 'Allen'



SELECT *
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID = 60000
 
SELECT * INTO OrdDet FROM Sales.SalesOrderDetail

CREATE INDEX idxOrdDetID ON OrdDet (SalesOrderDetailID);
 
SELECT *
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID = 1234;

SELECT *
FROM OrdDet
WHERE SalesOrderDetailID = 1234;
 

-- Filtered Indexes - 
-- Used when no of records that are searched often are realtively fewer in count compared to the entire table.
/*
CREATE NONCLUSTERED INDEX idx_Name
    ON Table(Cols)
    WHERE CONDITION 
*/

-- TODO : Indexed views
-- Refer this link - https://www.sqlshack.com/sql-server-indexed-views/
-- NOTE : index view dont work with STRING_AGG() function and Non-deterministic functions

-- Clustered and Non-C Indexes
-- Whe you creae atable w/o a Primary Key then we call it as a Stack table. 
-- Bascially every row is stacked one over the above
-- Clustered are created by default on PK and only one can be created on a table. This doesnot require seaparte table to be created for storing index
-- We can create multiple Non-C indexes and it require seaparate memory to store the index. 

-- TODO : DMVs Dynamic Management View
--refer Microsoft 

-- TODO : Columnstore vs Rowstore indexes

-- Diff between the belwo queries id the inclusion of NULL
-- SELECT * FROM TABLE WHERE column DISTINCT FROM value ....this includes all values other then value in that column including NULLs
-- SELECT * FROM TABLE WHERE column != value...this wont include NULLs


-- use Date_bucket for event tracking
DECLARE @date DATETIME2 = '2020-04-15 21:22:11';
SELECT DATE_BUCKET(SECOND, 1, @date) AS 'Second', DATE_BUCKET(MINUTE, 1, @date) AS 'Minute'
	, DATE_BUCKET(HOUR, 1, @date) AS 'Hour 1', DATE_BUCKET(HOUR, 2, @date) AS 'Hour 2', DATE_BUCKET(HOUR, 6, @date) AS 'Hour 3'
	, DATE_BUCKET(DAY, 1, @date)  AS 'Day 1', DATE_BUCKET(DAY, 2, @date) AS 'Day 2'
	, DATE_BUCKET(WEEK, 1, @date) AS 'Week', DATE_BUCKET(WEEK, 1, @date) AS 'WEEK 2'
	, DATE_BUCKET(MONTH, 1, @date) AS 'Month', DATE_BUCKET(MONTH, 1, @date) AS 'Month 2'


DROP TABLE IF EXISTS #SampleTempTable;
GO
CREATE TABLE #SampleTempTable (id INT, message nvarchar(50));
INSERT INTO #SampleTempTable VALUES (null, 'hello') ;
INSERT INTO #SampleTempTable VALUES (10, null);
INSERT INTO #SampleTempTable VALUES (17, 'abc');
INSERT INTO #SampleTempTable VALUES (17, 'yes');
INSERT INTO #SampleTempTable VALUES (null, null);
GO
 
-- The results exclude all rows where id matched the value of 17.
SELECT * FROM #SampleTempTable WHERE id IS DISTINCT FROM 17;
SELECT * FROM #SampleTempTable WHERE id <> 17; -- Doesn't show NULL
DROP TABLE IF EXISTS #SampleTempTable;
GO



-- TODO : Change Data capture
-- refer : implementing CDC - https://www.domo.com/glossary/cdc-sql#:~:text=1.%20Enable%20CDC%20at%20the%20database%20level%3A
-- refer : https://estuary.dev/blog/enable-sql-server-change-data-capture/
-- refer : https://hevodata.com/learn/sql-server-cdc/

-- Miscellaneous topics
use AdventureWorksDW2022

SELECT TOP 10 *
FROM DimCustomer
ORDER BY BirthDate DESC;  -- Gets the top 10 rows based on BirthDate in descending order

SELECT *
FROM DimCustomer
ORDER BY CustomerKey ASC  -- BirthDate ASC
OFFSET 10 ROWS
FETCH NEXT 5 ROWS ONLY; -- Skips the first 10 rows and retrieves the next 5
