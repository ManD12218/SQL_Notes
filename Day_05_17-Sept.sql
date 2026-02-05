
-- TODO INTERSECT, EXCEPT, UNION, UNION ALL



SELECT SalesOrderID
	,ProductID
	,UnitPrice
	,OrderQty
FROM sales.SalesOrderDetail
WHERE SalesOrderID=(SELECT max(SalesOrderID) FROM Sales.SalesOrderDetail)

SELECT * FROM FactInternetSales

-- Writing multivalued Query using both Subquery and join. Both takes the same time. 
-- For checking the time taken go to the third button on the right of EXECUTE button above and select both the queries.
SELECT SalesOrderNumber, SalesAmount
FROM FactInternetSales
WHERE CustomerKey IN (SELECT CustomerKey FROM DimCustomer WHERE GeographyKey=5)

SELECT fis.SalesOrderNumber, fis.SalesAmount
FROM FactInternetSales AS fis
JOIN DimCustomer AS dc ON fis.CustomerKey=dc.CustomerKey
WHERE GeographyKey=5

--Correlated Query
SELECT * FROM sales.SalesOrderHeader

SELECT SalesOrderID FROM sales.SalesOrderHeader
where SalesPersonID=279
order by SalesOrderID DESC

with cte as (SELECT soh01.SalesOrderID, soh01.SalesPersonID
FROM sales.SalesOrderHeader AS soh01
WHERE soh01.SalesOrderID=
	(SELECT Max(soh02.SalesOrderID) 
		FROM sales.SalesOrderHeader AS soh02
		WHERE soh01.SalesPersonID=soh02.SalesPersonID)
)
select * from cte where SalesPersonID=279

-- TODO : Try doinf the same with WINDOWS function

-- When EXISTS is used then it returns only TRUE/FALSE. 
-- In case there is even a single record to be returned then it returns TRUE otherwise it reutrns FALSE

select count(distinct(CustomerID)) from sales.Customer

select sc.CustomerID from sales.customer as sc
where exists 
(select * from sales.SalesOrderHeader as soh where soh.CustomerID=sc.CustomerID)
--19119

select distinct soh.CustomerID
from sales.SalesOrderHeader as soh
join sales.Customer as sc on soh.CustomerID=sc.CustomerID
--19119

-- When a subquery is written in from clause we cal it DERIVED TABLE. 
-- This is not used widely instead CTEs are mostly used.

--Common Table Expressions


WITH Sales_CTE (SalesPersonID, TotalSales, SalesYear)
AS
-- Define the first CTE query.
(
    SELECT SalesPersonID,
           SUM(TotalDue) AS TotalSales,
           YEAR(OrderDate) AS SalesYear
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID, YEAR(OrderDate)
), -- Use a comma to separate multiple CTE definitions.

-- Define the second CTE query, which returns sales quota data by year for each sales person.
Sales_Quota_CTE (BusinessEntityID, SalesQuota, SalesQuotaYear)
AS
(
    SELECT BusinessEntityID,
           SUM(SalesQuota) AS SalesQuota,
           YEAR(QuotaDate) AS SalesQuotaYear
    FROM Sales.SalesPersonQuotaHistory
    GROUP BY BusinessEntityID, YEAR(QuotaDate)
)
-- Define the outer query by referencing columns from both CTEs.
SELECT SalesPersonID,
       SalesYear,
       FORMAT(TotalSales, 'C', 'en-us') AS TotalSales,
       SalesQuotaYear,
       FORMAT(SalesQuota, 'C', 'en-us') AS SalesQuota,
       FORMAT(TotalSales - SalesQuota, 'C', 'en-us') AS Amt_Above_or_Below_Quota
FROM Sales_CTE
     INNER JOIN Sales_Quota_CTE
         ON Sales_Quota_CTE.BusinessEntityID = Sales_CTE.SalesPersonID
        AND Sales_CTE.SalesYear = Sales_Quota_CTE.SalesQuotaYear
ORDER BY SalesPersonID, SalesYear;


