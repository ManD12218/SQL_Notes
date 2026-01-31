SELECT * FROM [AdventureWorksDW2022].[dbo].[DimCustomer]
SELECT * FROM [AdventureWorksDW2022].[dbo].[DimGeography]

SELECT dc.CustomerKey,dc.FirstName,dc.LastName,dc.GeographyKey
	,dg.GeographyKey,dg.EnglishCountryRegionName,dg.StateProvinceCode,dg.City
	FROM DimCustomer as dc
	join DimGeography as dg on dc.GeographyKey = dg.GeographyKey

SELECT * from DimProductCategory
SELECT * from DimProductSubcategory
SELECT * from DimProduct

Select dps.ProductSubcategoryKey,dps.EnglishProductSubcategoryName,dps.ProductCategoryKey
		,dpc.ProductCategoryKey,dpc.EnglishProductCategoryName
from DimProductCategory as dpc
join DimProductSubcategory as dps ON dpc.ProductCategoryKey= dps.ProductCategoryKey


Select dp.ProductKey,dp.EnglishProductName,dp.ProductSubcategoryKey
		,dps.EnglishProductSubcategoryName,dps.ProductCategoryKey
		,dpc.ProductCategoryKey,dpc.EnglishProductCategoryName
from DimProduct as dp
join DimProductSubcategory as dps ON dp.ProductSubcategoryKey= dps.ProductSubcategoryKey
join DimProductCategory as dpc ON dpc.ProductCategoryKey= dps.ProductCategoryKey


Select  fis.ProductKey, fis.CustomerKey, fis.CurrencyKey, fis.SalesTerritoryKey, fis.SalesOrderNumber
		, fis.SalesOrderLineNumber, fis.OrderQuantity, fis.TotalProductCost, fis.SalesAmount
		, (fis.SalesAmount - fis.TotalProductCost) AS PROFIT

		,dp.ProductKey, dp.EnglishProductName, dp.ProductSubcategoryKey
		,dps.EnglishProductSubcategoryName, dps.ProductSubcategoryKey, dps.ProductCategoryKey
		,dpc.EnglishProductCategoryName, dpc.ProductCategoryKey
from FactInternetSales as fis
join DimProduct as dp ON dp.ProductKey=fis.ProductKey
join DimProductSubcategory as dps ON dp.ProductSubcategoryKey= dps.ProductSubcategoryKey
join DimProductCategory as dpc ON dpc.ProductCategoryKey= dps.ProductCategoryKey

where fis.SalesAmount - fis.TotalProductCost >1000 AND fis.CurrencyKey in (100,6)
order by profit desc

select * from DimCurrency
select * from FactInternetSales


Select  fis.ProductKey, fis.CustomerKey, fis.CurrencyKey, fis.SalesTerritoryKey, fis.SalesOrderNumber
		, fis.SalesOrderLineNumber, fis.OrderQuantity, fis.TotalProductCost, fis.SalesAmount
		, (fis.SalesAmount - fis.TotalProductCost) AS PROFIT

		,dp.ProductKey, dp.EnglishProductName, dp.ProductSubcategoryKey
		,dps.EnglishProductSubcategoryName, dps.ProductSubcategoryKey, dps.ProductCategoryKey
		,dpc.EnglishProductCategoryName, dpc.ProductCategoryKey

		,dc.CurrencyName
		,dst.SalesTerritoryCountry
		,cst.FirstName, cst.LastName, cst.GeographyKey
		,dg.EnglishCountryRegionName
from FactInternetSales as fis
join DimProduct as dp ON dp.ProductKey=fis.ProductKey
join DimProductSubcategory as dps ON dp.ProductSubcategoryKey= dps.ProductSubcategoryKey
join DimProductCategory as dpc ON dpc.ProductCategoryKey= dps.ProductCategoryKey
join DimCurrency as dc ON dc.CurrencyKey=fis.CurrencyKey
join DimSalesTerritory as dst ON dst.SalesTerritoryKey=fis.SalesTerritoryKey
join DimCustomer as cst ON cst.CustomerKey= fis.CustomerKey
join DimGeography as dg ON dg.GeographyKey=cst.GeographyKey

where fis.SalesAmount - fis.TotalProductCost >1000 AND fis.CurrencyKey in (100,6)
order by profit desc