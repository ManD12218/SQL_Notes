USE AdventureWorks2022

select * from sales.SalesOrderHeader
select * from sales.SalesOrderDetail

SELECT YEAR(soh.OrderDate) AS 'Year',
soh.CurrencyRateID,
SUM(sod.LineTotal) 'total order'
FROM 
Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY YEAR(soh.OrderDate), soh.CurrencyRateID



SELECT ROW_NUMBER() OVER (PARTITION BY YEAR(soh.OrderDate) ORDER BY SUM(sod.LineTotal) DESC) AS 'row_number',
YEAR(soh.OrderDate),
soh.CurrencyRateID,
SUM(sod.LineTotal) 'total order'
FROM 
Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY YEAR(soh.OrderDate), soh.CurrencyRateID




SELECT 
YEAR(soh.OrderDate) AS 'Year',
-- soh.CurrencyRateID,
SUM(sod.LineTotal) 'total order'
FROM 
Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY YEAR(soh.OrderDate)