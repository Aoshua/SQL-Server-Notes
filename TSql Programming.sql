DECLARE @MyInteger int = 30
DECLARE @1Password varchar

SET @MyInteger = 10
PRINT @MyInteger


SELECT
	@MyInteger = P.PersonID
FROM
	Application.People AS P

--ORDER BY PersonID

SELECT
	@MyInteger


SELECT * FROM Application.People WHERE IsSalesperson = 1


DECLARE @MyTable TABLE (MyTableKey int IDENTITY(1,1), SomeValue varchar(254))

--INSERT @MyTable (SomeValue) VALUES ('Red Sox'), ('Patriots')

INSERT @MyTable (SomeValue)
SELECT
	FullName
FROM
	Application.People
WHERE
	IsEmployee = 1

SELECT * FROM @MyTable



DECLARE @MyInteger int = 31
IF (@MyInteger >= 30)
BEGIN   --{
	IF (@MyInteger = 30)
		BEGIN
			PRINT 'Our Number is exactly 30'
		END
	ELSE IF (@MyInteger > 30 AND @MyInteger < 100)
		BEGIN
			PRINT 'Our number is bigger than 30 but less than 100'
		END
	ELSE
		BEGIN
			PRINT 'Our Number was greater than or equal 100'
		END
END  --}


DECLARE @Counter int = 10
WHILE (@Counter >= 0)
	BEGIN
		PRINT @Counter
		SET @Counter -= 1
		IF (@Counter = 5)
			BEGIN
				BREAK
			END
	END


DECLARE @Number int = 1
	BEGIN TRY
		PRINT @Number / 0	
	END TRY

	BEGIN CATCH
		PRINT 'Got an error'
		SELECT  
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH


SELECT
	1.0 + floor(6 * RAND(convert(varbinary, newid()))),
	PersonID,
	FullName
FROM
	Application.People
WHERE
	IsEmployee = 1

/*
Roll two dice 1000
Store the combined value, and the individual results in a table
Write a query to show the distribution of combined values
*/

SET NOCOUNT ON
DECLARE 
	@dice1 int,
	@dice2 int,
	@RollCounter int,
	@MaxRolls int

DECLARE @Results TABLE (Roll int, Dice1 int, Dice2 int) 
SET @RollCounter = 1
SET @MaxRolls = 500

WHILE (@RollCounter <= @MaxRolls)
BEGIN
	SET @dice1 = 1.0 + floor(6 * RAND(convert(varbinary, newid())))
	SET @dice2 = 1.0 + floor(6 * RAND(convert(varbinary, newid())))

	INSERT @Results (Roll, Dice1, Dice2) VALUES (@RollCounter, @dice1, @dice2)
	--PRINT @dice1
	--PRINT @dice2
	SET @RollCounter += 1

END

SELECT
	X.RollTotal,
	COUNT(X.RollTotal)
FROM
	(
	SELECT
		Dice1 + Dice2	[RollTotal]
	FROM
		@Results
	) X

GROUP BY
	X.RollTotal

ORDER BY
	X.RollTotal