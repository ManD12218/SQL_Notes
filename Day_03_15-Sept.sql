
--Brief explanation of First, second and  third Normal form

-- SQL Server Scalar functions
-- TODO - Go through the t-sql functions hosted on Microsoft website

Select * from DimCustomer

Select FirstName, MiddleName, LastName, FirstName + ' ' + MiddleName + '' + LastName
from DimCustomer --- if any of the 1st/middle/last name is Null then the resut is null

Select FirstName, MiddleName, LastName, CONCAT(FirstName,' ', MiddleName,' ', LastName) as fullName
from DimCustomer -- concat removes Null issue that happened with the above query

Select FirstName, MiddleName, LastName, CONCAT_WS(' ',FirstName, MiddleName, LastName) as fullName
from DimCustomer   --CONCAT_WS indicates concatenate with separator

--SOUNDEX function...0 score means very far away sounds and 4 means the sounds of the words are same. 
--DIFFERENCE function tells us this score
select soundex('praveen'),SOUNDEX('praviin'),DIFFERENCE('praveen','praviin')
select soundex('praveen'),SOUNDEX('traveen'),DIFFERENCE('praveen','traveen')


--FLOOR
select ExtendedAmount
	, floor(ExtendedAmount) as 'Floor' 
	, CEILING(ExtendedAmount) as 'Ceiling'
	, round(ExtendedAmount,0) AS 'Round0'
	, round(ExtendedAmount,1) AS 'Round1'
	, round(ExtendedAmount,2) AS 'Round2' 	
from FactInternetSales
--NOTE: Round 0 truncate and outputs still in the same decimal datatype and not integer. 


--LTRIM
select CustomerKey, FirstName + ' has yearly income of ' + LTRIM(str(YearlyIncome,15,2))
from DimCustomer

-- STRING_AGG is an aggregate function that takes all expressions from rows and 
-- concatenates them into a single string.
select string_agg(convert(nvarchar(max),firstName),'--') as CSV
from DimCustomer

--How to get the server name and other such details
select @@SERVERNAME as 'Servername'
select @@SPID, SYSTEM_USER, user as 'user'
select @@VERSION

--DATETIME functions
select 	SYSDATETIME ( ) --outputs the cliets timedatetime
select SYSDATETIMEOFFSET ( ) --includes timeoffset as well
select 	SYSUTCDATETIME ( ) --returns the UTC time of this system
select GETDATE ( ); -- The above 3 outputs higher precision values and getdate() Outputs lower precsion
SELECT CAST(GETDATE() AS DATE)

SELECT DATE_BUCKET(DAY, 10, getdate())
SELECT DATE_BUCKET(Year, 10, getdate())

-- TODO 
--DATEADD, DATEDIFF and other date functions
-- CHOOSE, IIF, GREATEST and LEAST



select * from FactInternetSales

select SalesAmount, TotalProductCost, (SalesAmount-TotalProductCost) as 'Profit' 
from FactInternetSales
Order by Profit

SELECT SalesAmount, TotalProductCost,
IIF((SalesAmount - TotalProductCost) > 1000, 'High Value', IIF((SalesAmount - TotalProductCost) > 500,'Mid value', 'low value')) as 'Trans_type'
FROM FactInternetSales
-- The same query can be written with CASE WHEN as well

-- TODO - CAST and CONVERT

