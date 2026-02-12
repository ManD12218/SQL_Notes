--UDF
Create or alter function GiveMeSquare (@x1 float)
returns float
As begin
	return (@x1 * @x1)
End;

select dbo.GiveMeSquare(3)

select SalesAmount, dbo.GiveMeSquare(salesAmount)
from FactInternetSales

Drop function GiveMeSquare



Create or Alter function CheckCustomer(@custKey int)
RETURNS BIT
AS BEGIN
	Declare @result BIT
	IF EXISTS( select 1 from DimCustomer
				WHERE CustomerKey=@custKey )
		set @result = 1
	ELSE
		set @result = 0
	return @result
END;

select * from DimCustomer
select dbo.CheckCustomer(CustomerKey) from DimCustomer where CustomerKey = 110

-- Deterministc vs Non_D functions 
-- Functions that return a fixed value are detereminstic but Non- D returns a dynamic value such as todays_date() would return 
--different value every other day

-- Inline Table-valued function
-- These are sigle line functions without BEGIN and the entire logic is in the reurn statement itself
create or alter function sales.GetLastOrdersForCustomers(
@CustomerID int, @NumberOfOrders int)
Returns TABLE
As
Return (select top(@NumberOfOrders) soh.SalesOrderID
			, soh.OrderDate
			, soh.PurchaseOrderNumber
			from sales.SalesOrderHeader as soh
			where soh.CustomerID= @CustomerID AND soh.PurchaseOrderNumber IS NOT NULL
			order by soh.OrderDate DESC, soh.SalesOrderID DESC
			);

select * from sales.GetLastOrdersForCustomers(29825,3)
select * from sales.SalesOrderHeader

select * from dbo.FactInternetSales
select * from DimCurrency
select * from DimCustomer
-- Write query showing Top 3 currency names with their sum of sales
-- Display currency name and salesamount

CREATE or ALTER FUNCTION udf_GetTopCurrency(
@NumberOfCurrency int)
RETURNS TABLE
AS
RETURN (
	SELECT TOP(@NumberOfCurrency) 
		  fis.CurrencyKey
		, dc.CurrencyName
		, ROUND(SUM(fis.SalesAmount),2) AS TotalSales
	FROM dbo.FactInternetSales AS fis
	LEFT JOIN dbo.DimCurrency AS dc
		ON fis.CurrencyKey=dc.CurrencyKey
	GROUP BY fis.CurrencyKey, dc.CurrencyName
	ORDER BY TotalSales DESC
	);

SELECT * FROM udf_GetTopCurrency(3)



--CREATE or ALTER FUNCTION udf_GetTopCurrencyNew(
--@NumberOfCurrency int)
--RETURNS TABLE
--AS
--RETURN (

with cte as (
select dc.CurrencyName,dcu.FirstName,SUM(fis.SalesAmount) AS TotalSales, 
rk=row_number() over (partition by dc.CurrencyName order by SUM(fis.SalesAmount) DESC)
from dbo.FactInternetSales as fis
left join DimCustomer as dcu ON fis.CustomerKey=dcu.CustomerKey
left join DimCurrency as dc ON fis.CurrencyKey=dc.CurrencyKey
group by dc.CurrencyName,dcu.FirstName
)

select CurrencyName,FirstName,TotalSales
from cte 
where rk <= 3



-- Multivalued Table valued function
CREATE OR ALTER FUNCTION dbo.GetDateRange(
@StartDate date, @NumberOfDays int
)
RETURNS @DateList TABLE (Position int, DateValue DATE)
AS 
BEGIN
	DECLARE @counter int = 0
	WHILE (@counter < @NumberOfDays) 
	BEGIN
		INSERT INTO @DateList VALUES (@counter + 1, DATEADD(day,@counter,@StartDate));
		set @counter +=1
	END;
	RETURN;
END;

GO

select * from dbo.GetDateRange('2009-12-31',10)


--TODO : Compare Table valued function both single line and multiline with views


-- STORED PROCEDURE
CREATE OR ALTER	PROCEDURE usp_TerritoryWiseSales
AS 
BEGIN
	SELECT fis.SalesTerritoryKey, dst.SalesTerritoryCountry, SUM(fis.salesAmount) AS 'Sales'
	FROM FactInternetSales as fis
	JOIN DimSalesTerritory as dst ON fis.SalesTerritoryKey = dst.SalesTerritoryKey
	group by fis.SalesTerritoryKey,  dst.SalesTerritoryCountry
	ORDER BY 'Sales' DESC
END;

EXEC usp_TerritoryWiseSales

-- Can we use select to query a SP? NO
SELECT * from usp_TerritoryWiseSales
SELECT * from DimCustomer

-- NOTE: We can pass parameters to the SP 
CREATE OR ALTER PROCEDURE uspGetCustomerCompany1
    @FN nvarchar(50),
	@LN nvarchar(50)
AS   

    SET NOCOUNT ON;
    SELECT FirstName, LastName, GeographyKey
    FROM DimCustomer
    WHERE FirstName = @FN AND LastName = @LN;
GO

EXEC uspGetCustomerCompany1 'Jon', 'Yang'
EXEC uspGetCustomerCompany1 @LN='Yang', @FN='Jon'
