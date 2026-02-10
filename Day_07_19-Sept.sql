 --Top reseller per employee

select * from FactInternetSales
select * from FactResellerSales
select * from DimSalesTerritory
select * from DimProduct

partition via each employeeKey 
order by the salesAmount Desc
print resellerKey for Max(salesAmount)

with cte as (
select EmployeeKey, ResellerKey,SalesAmount ,rk=RANK() over (partition by employeeKey order by salesAmount Desc)
from FactResellerSales
)
select EmployeeKey,ResellerKey from cte where rk=1


-- STORED PROCEDURE and DYNAMIC QUERY

USE AdventureWorks2022;
GO

DECLARE @SQLString AS NVARCHAR (500);
DECLARE @ParmDefinition AS NVARCHAR (500);
DECLARE @SalesOrderNumber AS NVARCHAR (25);
DECLARE @IntVariable AS INT;

SET @SQLString = N'SELECT @SalesOrderOUT = MAX(SalesOrderNumber)
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID';

SET @ParmDefinition = N'@CustomerID INT,
    @SalesOrderOUT NVARCHAR(25) OUTPUT';

SET @IntVariable = 22276;

EXECUTE sp_executesql
    @SQLString,
    @ParmDefinition,
    @CustomerID = @IntVariable,
    @SalesOrderOUT = @SalesOrderNumber OUTPUT;

-- This SELECT statement returns the value of the OUTPUT parameter.
SELECT @SalesOrderNumber;

-- This SELECT statement uses the value of the OUTPUT parameter in
-- the WHERE clause.
SELECT OrderDate,
       TotalDue
FROM Sales.SalesOrderHeader
WHERE SalesOrderNumber = @SalesOrderNumber;

SELECT SalesOrderNumber
    FROM Sales.SalesOrderHeader

-- VIEW
--NOTE: We cannot use ORDER BY inside a CREATE VIEW statement without TOP() in the select. 
--This is because a VIEW is unordered set of rows just like a logical table. 
--ORDER BY otherwise will bake the order inside the view which is against this logical table.


--SCHEMABINDING and ENCRYPTION
use AdventureWorksDW2022
Create Table t1 (
ID INT,
FN VARCHAR(50)
)
-- tO SEE THE NEWLY CREATED tABLE AND vIEWS YOU HAVE TO GO TO db<tbale/view<right click on it and hit REFRESH
Create or alter View v1 with schemabinding 
as
select ID, FN from dbo.t1

select * from dbo.t1
select * from v1

Create or alter View v1
with schemabinding, Encryption
as
select ID, FN from dbo.t1;

select definition from sys.sql_modules
where object_id = OBJECT_ID('dbo.v1')
-- NOTE: we can see that the definitin column un sql_module is coming as NULL when encryption is used

--UDF
Create or alter function GiveMeSquare (@x1 float)
returns float
As begin
	return (@x1 * @x1)
End;

select dbo.GiveMeSquare(3)

select SalesAmount, dbo.GiveMeSquare(salesAmount)
from FactInternetSales

