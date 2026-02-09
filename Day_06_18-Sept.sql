-- Are ther any customers that never ordered using OLTP DB
-- Any product never ordered

SELECT * FROM DimCustomer
SELECT * FROM FactInternetSales
select * from DimProduct

SELECT CustomerKey
FROM DimCustomer
WHERE customerkey NOT IN (SELECT CustomerKey FROM FactInternetSales)

SELECT ProductKey
FROM DimProduct
WHERE ProductKey NOT IN (SELECT ProductKey FROM FactInternetSales)
order by ProductKey


select * from sales.SalesOrderDetail

select CustomerID
from sales.Customer
where CustomerID NOT IN (select CustomerID from sales.SalesOrderDetail)

Select ProductID
from Production.Product
where ProductID NOT IN (select ProductID from sales.SalesOrderDetail)

select * from sales.SalesOrderDetail
where ProductID in (474,365)

--Creating a table
-- NVARCHAR can store non-english characters

-- Create an Employee table.
CREATE TABLE dbo.MyEmployees
(
    EmployeeID SMALLINT NOT NULL,
    FirstName NVARCHAR (30) NOT NULL,
    LastName NVARCHAR (40) NOT NULL,
    Title NVARCHAR (50) NOT NULL,
    DeptID SMALLINT NOT NULL,
    ManagerID SMALLINT NULL,
    CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC),
    CONSTRAINT FK_MyEmployees_ManagerID_EmployeeID FOREIGN KEY (ManagerID) REFERENCES dbo.MyEmployees (EmployeeID)
);

-- Populate the table with values.
INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer', 16, NULL),
(273, N'Brian', N'Welcker', N'Vice President of Sales', 3, 1),
(274, N'Stephen', N'Jiang', N'North American Sales Manager', 3, 273),
(275, N'Michael', N'Blythe', N'Sales Representative', 3, 274),
(276, N'Linda', N'Mitchell', N'Sales Representative', 3, 274),
(285, N'Syed', N'Abbas', N'Pacific Sales Manager', 3, 273),
(286, N'Lynn', N'Tsoflias', N'Sales Representative', 3, 285),
(16, N'David', N'Bradley', N'Marketing Manager', 4, 273),
(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);


--Recursive queries
With DirectReports (ManagerID, EmployeeID, Title, EmployeeLevel ) AS
(
	SELECT ManagerID, EmployeeID, Title, 0 AS EmployeeLevel
	FROM dbo.MyEmployees
	WHERE ManagerID IS NULL  -- ANCHOR QUERY (BASE CASE). This will only run once. 
	UNION ALL
	SELECT e.ManagerID, e.EmployeeID, e.Title, EmployeeLevel + 1
	FROM dbo.MyEmployees AS e
	JOIN DirectReports AS d
		ON e.ManagerID=d.employeeID -- RECURSIVE PART
)
select ManagerID, EmployeeID, Title, EmployeeLevel
from DirectReports
ORDER BY ManagerID

-- TODO - READ - https://learn.microsoft.com/en-us/sql/t-sql/queries/recursive-common-table-expression-transact-sql?view=sql-server-ver17

-- WITH TIES
select * from sales.SalesTerritory

select TOP(3) TerritoryID, SalesYTD 
from sales.SalesTerritory
order by SalesYTD DESC

select TOP(3) WITH TIES TerritoryID, SalesYTD 
from sales.SalesTerritory
order by SalesYTD DESC


-- PIVOT
USE AdventureWorksDW2022

SELECT SalesTerritoryKey, SUM(SalesAmount) as SumOfSales from FactInternetSales
group by SalesTerritoryKey
order by SalesTerritoryKey

SELECT 'SumOfSales' AS SalesTerritory, [1],[2],[3],[4],[5],[6],[7],[8],[9],[10]
FROM (SELECT SalesTerritoryKey, SalesAmount FROM FactInternetSales
) AS sourceTable 
PIVOT ( SUM(SalesAmount) FOR SalesTerritoryKey IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10]) )
AS PivotTable
-- TODO : Show numbers in Rupees
-- Add TerritoryName instead TerritoryKey

select * from DimSalesTerritory

With cte as (
SELECT 'SumOfSales' AS SalesTerritory, ['Australia'],['United Kingdom']
FROM (SELECT fis.SalesTerritoryKey, fis.SalesAmount, dst.SalesTerritoryRegion
		FROM FactInternetSales as fis 
		JOIN DimSalesTerritory as dst
		ON fis.SalesTerritoryKey=dst.SalesTerritoryKey
		where dst.SalesTerritoryKey in (9,10)
) AS sourceTable 
PIVOT ( SUM(SalesAmount) FOR SalesTerritoryKey IN ( ['Australia'],['United Kingdom']) )
AS PivotTable
)
select format(  ['Australia'], 'C', 'en-in'),format(['United Kingdom'] , 'C', 'en-in') from cte




--
select * from FactInternetSales
select * from FactResellerSales
select * from DimSalesTerritory
select * from DimProduct
-- Display SalesTerritory name, productName, Total Profit. Include the records from both fis and frs

 Add both fis and frs. 
 Then group by productkey
 then join with dimproduct to fetch product name
 then join with salesterrotry to get territory name

 with cte as (
 select ProductKey, (SalesAmount-TotalProductCost) as Profit, SalesTerritoryKey from FactInternetSales
 UNION ALL
 select ProductKey, (SalesAmount-TotalProductCost) as Profit,SalesTerritoryKey from FactResellerSales
 )

 select  dst.SalesTerritoryRegion, dp.EnglishProductName, sum(c.Profit)  from cte as c
 join DimProduct as dp ON c.ProductKey=dp.ProductKey
 join DimSalesTerritory as dst ON c.SalesTerritoryKey=dst.SalesTerritoryKey
 group by dst.SalesTerritoryRegion, dp.EnglishProductName
 order by dst.SalesTerritoryRegion, sum(c.Profit) DESC


