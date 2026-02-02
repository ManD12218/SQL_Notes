
SELECT count(*)
  FROM [AdventureWorksDW2022].[dbo].[DimProduct]   --606

SELECT count(distinct ProductKey)
  FROM [AdventureWorksDW2022].[dbo].[DimProduct]   --606

SELECT count(distinct ProductKey)                  
  FROM FactInternetSales							--158

Select dc.*, fis.ProductKey, fis.OrderQuantity
  From DimCurrency as dc
  Join FactInternetSales as fis ON dc.CurrencyKey = fis.CurrencyKey  --60398

Select dc.*, fis.ProductKey, fis.OrderQuantity
  From DimCurrency as dc
  Left Join FactInternetSales as fis ON dc.CurrencyKey = fis.CurrencyKey  --60497


select * from DimProduct --606
select * from DimProductCategory  --4
select * from DimProductSubcategory  --37


-- Edit DimProductCategory table and add one more record. 
-- You have to go to the table in the left index and then click "" Edit top 200 rows. 
-- Once you add values the primary key if autoincrement then  will automatically... 
-- ....increment as soon as you click any of the record existed before.

select *
from DimProductCategory as dpc
left join DimProductSubcategory as psc ON dpc.ProductCategoryKey=psc.ProductCategoryKey  --38

select *
from DimProductSubcategory as psc
left join DimProductCategory as dpc ON dpc.ProductCategoryKey=psc.ProductCategoryKey  --37



-- Assignment


Select dp.ProductKey, dp.EnglishProductName, 
	 fis.OrderQuantity, fis.SalesAmount
  From DimProduct as dp
  Join FactInternetSales as fis ON dp.ProductKey = fis.ProductKey  --60398

Select dp.ProductKey, dp.EnglishProductName, 
	 fis.OrderQuantity, fis.SalesAmount
  From DimProduct as dp
  Left Join FactInternetSales as fis ON dp.ProductKey = fis.ProductKey  --60846


Select fis.ProductKey, dp.EnglishProductName,  sum(fis.SalesAmount) as Sales
  From  FactInternetSales as fis
  Join DimProduct as dp ON fis.ProductKey=dp.ProductKey
  group by fis.ProductKey, dp.EnglishProductName


Select fis.ProductKey, dp.EnglishProductName,  sum(fis.SalesAmount) as Sales
  From  DimProduct as dp
  left Join FactInternetSales as fis ON fis.ProductKey=dp.ProductKey
  group by fis.ProductKey, dp.EnglishProductName


select dc.CurrencyKey, dc.CurrencyName, count(fis.ProductKey), sum(fis.salesAmount), AVG(fis.SalesAmount)
	from DimCurrency as dc
	Left join FactInternetSales as fis ON fis.CurrencyKey = dc.CurrencyKey
	group by dc.CurrencyKey, dc.CurrencyName


-- Add a new subcategory 
-- Show productSubCategoryName wise Sum of Sales...even if the subcategory doesn't have any sales, still list it it

select psc.EnglishProductSubcategoryName, SUM(fis.SalesAmount) as sales
from DimProductSubcategory as psc
left join DimProduct as dp ON dp.ProductSubcategoryKey=psc.ProductSubcategoryKey
Left join FactInternetSales as fis ON dp.ProductKey = fis.ProductKey
where fis.SalesAmount>9 
group by psc.EnglishProductSubcategoryName
having SUM(fis.SalesAmount)>19500
order by sales

-- Full Outer join
select *
from DimProductCategory as dpc
full outer join DimProductSubcategory as psc ON dpc.ProductCategoryKey = psc.ProductCategoryKey

-- cross join

Select *
from DimProductCategory
cross join DimProductSubcategory

--NOTE: Left outer join is same as Left join

--Equi Join : any query with equal operator. Similarly Non-Equi join is all using <>,<=,>=
select *
from DimProductCategory as dpc, DimProductSubcategory as psc
where dpc.ProductCategoryKey = psc.ProductCategoryKey
-- standard joins are preferred then the above way of using equi join. 

-- E.g of Non-equi Join
--SELECT student.name, record.id, record.city
--FROM student, record
--WHERE student.id < record.id;


--Self Join
select de.EmployeeKey, de.ParentEmployeeKey, de.FirstName, mgr.FirstName as [Manager's name]
from DimEmployee as de
Left join DimEmployee as mgr ON de.ParentEmployeeKey=mgr.EmployeeKey

select de.EmployeeKey, de.ParentEmployeeKey, de.FirstName, mgr.FirstName as [Manager's name]
from DimEmployee as de
Inner join DimEmployee as mgr ON de.ParentEmployeeKey=mgr.EmployeeKey