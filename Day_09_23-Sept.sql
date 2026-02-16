
--Store procedure

--Dummy Table
CREATE TABLE CustomerData (
ID INT PRIMARY KEY,
FN NVARCHAR(50) NOT NULL,
Balance INT Check (Balance >=0)
)

--INSERT VALUES
INSERT INTO CustomerData (ID,FN,Balance)
VALUES
(1,'A',10),
(2,'B',10)

select * from CustomerData


CREATE OR ALTER PROCEDURE UpTransferAmount
@fromID INT,
@toID INT,
@amount INT

AS
BEGIN

-- Validate the FROM Account 
IF NOT EXISTS (SELECT * FROM CustomerData where ID=@fromID)
BEGIN
	RAISERROR ('FROM Account doesnot exists',16,1)
	RETURN;
END;
PRINT 'FROM Account is valid'

-- Validate the TO Account
IF NOT EXISTS (SELECT * FROM CustomerData where ID=@toID)
BEGIN
	RAISERROR ('TO Account doesnot exists',16,1)
	RETURN;
END;
PRINT 'TO Account is valid'
END;

EXEC UpTransferAmount 1,2,50
EXEC UpTransferAmount 1,3,50
EXEC UpTransferAmount 10,2,50
EXEC UpTransferAmount 1,2,5000


-- Writing a UDF to validate IDs
CREATE OR ALTER FUNCTION udf_validation (@IDToValidate INT)
RETURNS INT
AS 
BEGIN
IF NOT EXISTS (SELECT * FROM CustomerData WHERE ID=@IDToValidate)
	RETURN -1;
RETURN 1;
END;


CREATE OR ALTER PROCEDURE UpTransferAmount
@fromID INT,
@toID INT,
@amount INT

AS
BEGIN
-- Validate the FROM Account 
IF dbo.udf_validation(@fromID)=-1
	THROW 51000, 'FROM Account is INVALID', 1;
PRINT 'FROM Account is valid'

-- Validate the TO Account
IF dbo.udf_validation(@toID)=-1
	THROW 51000, 'TO Account is INVALID', 1;
PRINT 'TO Account is valid'
-- NOTE: RAISERROR is deprecated which means its support is no lnger available in the newer versions and
-- THROW is used instead. THROW cannot be used inside a UDF but can be used inside a SP.
UPDATE CustomerData
SET Balance= Balance + @amount
WHERE ID=@toID
PRINT 'Amount Credited to toID Account'


UPDATE CustomerData
SET Balance= Balance - @amount
WHERE ID=@fromID
PRINT 'Amount Debited from fromID Account'
END;


SELECT * FROM CustomerData
EXEC UpTransferAmount 1,2,50
/* Now we observed that the on executing the stored procedure untill 
one of the account went to zero seems no issues but executing after the debitors acoount went zero
gives us error - 'The UPDATE statement conflicted with the CHECK constraint "CK__CustomerD__Balan__531856C7".'
Although an error is thrown the amount is also credited to the creditors account!
*/

CREATE OR ALTER PROCEDURE UpTransferAmount
@fromID INT,
@toID INT,
@amount INT

AS
BEGIN
-- Validate the FROM Account 
IF dbo.udf_validation(@fromID)=-1
	THROW 51000, 'FROM Account is INVALID', 1;
PRINT 'FROM Account is valid'

-- Validate the TO Account
IF dbo.udf_validation(@toID)=-1
	THROW 51000, 'TO Account is INVALID', 1;
PRINT 'TO Account is valid'

BEGIN TRY
	PRINT 'INISDE TRY BLOCK'
	BEGIN TRANSACTION

	UPDATE CustomerData
	SET Balance= Balance + @amount
	WHERE ID=@toID
	PRINT 'Amount Credited to toID Account'


	UPDATE CustomerData
	SET Balance= Balance - @amount
	WHERE ID=@fromID
	PRINT 'Amount Debited from fromID Account'

	COMMIT TRANSACTION
	PRINT 'COMMIT DONE'
END TRY
BEGIN CATCH
	PRINT 'INSIDE CATCH'
	ROLLBACK TRANSACTION
	PRINT 'ROLLBACK...done succesfully';
	--THROW 51000, 'Transaction declined',10
	--THROW;
END CATCH;
END;

UPDATE CustomerData
SET Balance=5

SELECT * FROM CustomerData
EXEC UpTransferAmount 1,2,1


-- The below is the way a program calls a SP. 
-- NOTE : THe execution of below code when the stored procedure 
-- 1. omits THROW statement
-- 2. THROW with a user defined statement

BEGIN TRY
    PRINT 'Inside caller';
    EXEC UpTransferAmount 1, 2, 1;
    PRINT 'SUCCESS - back in caller';
    RETURN;
END TRY
BEGIN CATCH
    PRINT 'Inside CATCH of caller'
     SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage; 
END CATCH

