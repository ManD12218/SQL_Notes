
-- Partitioning Tables
CREATE DATABASE PartitionTest;
GO

-- Create a partitioned table on one filegroup
CREATE PARTITION FUNCTION myRangePF1 (datetime2(0))
    AS RANGE RIGHT FOR VALUES ('2022-04-01', '2022-05-01', '2022-06-01') ;
GO

CREATE PARTITION SCHEME myRangePS1
    AS PARTITION myRangePF1
    ALL TO ('PRIMARY') ;
GO

CREATE TABLE dbo.PartitionTable (col1 datetime2(0) PRIMARY KEY, col2 char(10))
    ON myRangePS1 (col1) ;
GO

--Create a partitioned table on multiple filegroups
USE PartitionTest;
GO

ALTER DATABASE PartitionTest
ADD FILEGROUP test1fg;
GO
ALTER DATABASE PartitionTest
ADD FILEGROUP test2fg;
GO
ALTER DATABASE PartitionTest
ADD FILEGROUP test3fg;
GO
ALTER DATABASE PartitionTest
ADD FILEGROUP test4fg;

ALTER DATABASE PartitionTest
ADD FILE
(
    NAME = partitiontest1,
    FILENAME = 'C:\SSMS_Partition_tables\partitiontest1.ndf',
    SIZE = 5MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP test1fg;
ALTER DATABASE PartitionTest
ADD FILE
(
    NAME = partitiontest2,
    FILENAME = 'C:\SSMS_Partition_tables\partitiontest2.ndf',
    SIZE = 5MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP test2fg;
GO
ALTER DATABASE PartitionTest
ADD FILE
(
    NAME = partitiontest3,
    FILENAME = 'C:\SSMS_Partition_tables\partitiontest3.ndf',
    SIZE = 5MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP test3fg;
GO
ALTER DATABASE PartitionTest
ADD FILE
(
    NAME = partitiontest4,
    FILENAME = 'C:\SSMS_Partition_tables\partitiontest4.ndf',
    SIZE = 5MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP test4fg;
GO

CREATE PARTITION FUNCTION myRangePF1 (datetime2(0))
    AS RANGE RIGHT FOR VALUES ('2022-04-01', '2022-05-01', '2022-06-01') ;
GO

CREATE PARTITION SCHEME myRangePS1
    AS PARTITION myRangePF1
    TO (test1fg, test2fg, test3fg, test4fg) ;
GO

CREATE TABLE PartitionTable (col1 datetime2(0) PRIMARY KEY, col2 char(10))
    ON myRangePS1 (col1) ;
GO




drop table PartitionTable

--Insert values in to the partitions
INSERT INTO dbo.PartitionTable Values ('2022-03-01','mandeep')
INSERT INTO dbo.PartitionTable Values ('2022-02-01','mandeep')
INSERT INTO dbo.PartitionTable Values ('2022-04-01','Four')
INSERT INTO dbo.PartitionTable Values ('2022-05-01','Five')
INSERT INTO dbo.PartitionTable Values ('2022-06-01','Six')
INSERT INTO dbo.PartitionTable Values ('2022-07-01','Seven')
INSERT INTO dbo.PartitionTable Values ('2022-08-01','mandeep')
select * from dbo.PartitionTable

-- Find how many rows are there in which partition
SELECT * FROM sys.dm_db_partition_stats   
WHERE object_id = OBJECT_ID('PartitionTable');
GO

-- Identify the boundry values for the partition
SELECT SCHEMA_NAME(t.schema_id) AS SchemaName, t.name AS TableName, i.name AS IndexName,
    p.partition_number, p.partition_id, i.data_space_id, f.function_id, f.type_desc,
    r.boundary_id, r.value AS BoundaryValue
FROM sys.tables AS t
JOIN sys.indexes AS i ON t.object_id = i.object_id
JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN  sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
JOIN sys.partition_functions AS f ON s.function_id = f.function_id
LEFT JOIN sys.partition_range_values AS r ON f.function_id = r.function_id and r.boundary_id = p.partition_number
WHERE t.name = 'PartitionTable' AND i.type <= 1
ORDER BY SchemaName, t.name, i.name, p.partition_number;



-- identify the column on which partitioning is done
SELECT
    t.[object_id] AS ObjectID
    , SCHEMA_NAME(t.schema_id) AS SchemaName
    , t.name AS TableName
    , ic.column_id AS PartitioningColumnID
    , c.name AS PartitioningColumnName
    , i.name as IndexName
FROM sys.tables AS t
JOIN sys.indexes AS i ON t.[object_id] = i.[object_id] AND i.[type] <= 1 -- clustered index or a heap
JOIN sys.partition_schemes AS ps ON ps.data_space_id = i.data_space_id
JOIN sys.index_columns AS ic ON ic.[object_id] = i.[object_id]
    AND ic.index_id = i.index_id
    AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column
JOIN sys.columns AS c ON t.[object_id] = c.[object_id] AND ic.column_id = c.column_id
WHERE t.name = 'PartitionTable';

-- Determine the rows describe the possible range of values in each partition
SELECT SCHEMA_NAME(t.schema_id) AS SchemaName, t.name AS TableName, i.name AS IndexName,
    p.partition_number AS PartitionNumber, f.name AS PartitionFunctionName, p.rows AS Rows, rv.value AS BoundaryValue,
CASE WHEN ISNULL(rv.value, rv2.value) IS NULL THEN 'N/A'
ELSE
    CASE WHEN f.boundary_value_on_right = 0 AND rv2.value IS NULL THEN '>='
        WHEN f.boundary_value_on_right = 0 THEN '>'
        ELSE '>='
    END + ' ' + ISNULL(CONVERT(varchar(64), rv2.value), 'Min Value') + ' ' +
        CASE f.boundary_value_on_right WHEN 1 THEN 'and <'
                ELSE 'and <=' END
        + ' ' + ISNULL(CONVERT(varchar(64), rv.value), 'Max Value')
END AS TextComparison
FROM sys.tables AS t
JOIN sys.indexes AS i  ON t.object_id = i.object_id
JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN  sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
JOIN sys.partition_functions AS f ON s.function_id = f.function_id
LEFT JOIN sys.partition_range_values AS r ON f.function_id = r.function_id and r.boundary_id = p.partition_number
LEFT JOIN sys.partition_range_values AS rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
LEFT JOIN sys.partition_range_values AS rv2 ON f.function_id = rv2.function_id
    AND p.partition_number - 1= rv2.boundary_id
WHERE t.name = 'PartitionTable' AND i.type <= 1
ORDER BY t.name, p.partition_number;


-- Alter partition function 
/*
-- This is how original partitions were created. This is just for the reference.
-- CREATE PARTITION FUNCTION myRangePF1 (datetime2(0))
--    AS RANGE RIGHT FOR VALUES ('2022-04-01', '2022-05-01', '2022-06-01') ;
*/
ALTER PARTITION FUNCTION myRangePF1()
MERGE RANGE ('2022-05-01')


-- Determine the rows describe the possible range of values in each partition
SELECT SCHEMA_NAME(t.schema_id) AS SchemaName, t.name AS TableName, i.name AS IndexName,
    p.partition_number AS PartitionNumber, f.name AS PartitionFunctionName, p.rows AS Rows, rv.value AS BoundaryValue,
CASE WHEN ISNULL(rv.value, rv2.value) IS NULL THEN 'N/A'
ELSE
    CASE WHEN f.boundary_value_on_right = 0 AND rv2.value IS NULL THEN '>='
        WHEN f.boundary_value_on_right = 0 THEN '>'
        ELSE '>='
    END + ' ' + ISNULL(CONVERT(varchar(64), rv2.value), 'Min Value') + ' ' +
        CASE f.boundary_value_on_right WHEN 1 THEN 'and <'
                ELSE 'and <=' END
        + ' ' + ISNULL(CONVERT(varchar(64), rv.value), 'Max Value')
END AS TextComparison
FROM sys.tables AS t
JOIN sys.indexes AS i  ON t.object_id = i.object_id
JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN  sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
JOIN sys.partition_functions AS f ON s.function_id = f.function_id
LEFT JOIN sys.partition_range_values AS r ON f.function_id = r.function_id and r.boundary_id = p.partition_number
LEFT JOIN sys.partition_range_values AS rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
LEFT JOIN sys.partition_range_values AS rv2 ON f.function_id = rv2.function_id
    AND p.partition_number - 1= rv2.boundary_id
WHERE t.name = 'PartitionTable' AND i.type <= 1
ORDER BY t.name, p.partition_number;


-- Add the filegroup again to the Scheme before split
ALTER PARTITION SCHEME myRangePS1 NEXT USED test2fg;
 
-- Split the partition into 2
ALTER PARTITION FUNCTION myRangePF1  () SPLIT RANGE ( '2022-05-01' )

-- Check the partitions after SPLIT RANGE
-- Determine the rows describe the possible range of values in each partition
SELECT SCHEMA_NAME(t.schema_id) AS SchemaName, t.name AS TableName, i.name AS IndexName,
    p.partition_number AS PartitionNumber, f.name AS PartitionFunctionName, p.rows AS Rows, rv.value AS BoundaryValue,
CASE WHEN ISNULL(rv.value, rv2.value) IS NULL THEN 'N/A'
ELSE
    CASE WHEN f.boundary_value_on_right = 0 AND rv2.value IS NULL THEN '>='
        WHEN f.boundary_value_on_right = 0 THEN '>'
        ELSE '>='
    END + ' ' + ISNULL(CONVERT(varchar(64), rv2.value), 'Min Value') + ' ' +
        CASE f.boundary_value_on_right WHEN 1 THEN 'and <'
                ELSE 'and <=' END
        + ' ' + ISNULL(CONVERT(varchar(64), rv.value), 'Max Value')
END AS TextComparison
FROM sys.tables AS t
JOIN sys.indexes AS i  ON t.object_id = i.object_id
JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN  sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
JOIN sys.partition_functions AS f ON s.function_id = f.function_id
LEFT JOIN sys.partition_range_values AS r ON f.function_id = r.function_id and r.boundary_id = p.partition_number
LEFT JOIN sys.partition_range_values AS rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
LEFT JOIN sys.partition_range_values AS rv2 ON f.function_id = rv2.function_id
    AND p.partition_number - 1= rv2.boundary_id
WHERE t.name = 'PartitionTable' AND i.type <= 1
ORDER BY t.name, p.partition_number;


-- CASE STATEMENTS
USE AdventureWorksDW2022
GO
SELECT * FROM FactInternetSales

SELECT OrderDate
	, SalesAmount
	, CASE WHEN SalesAmount <=1000 THEN 'Low Value'
		WHEN SalesAmount <=3400 THEN 'Mid Value'
		ELSE 'High Value'
	END AS 'CATEGORY'
FROM FactInternetSales

