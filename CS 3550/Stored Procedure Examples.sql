DROP TABLE ExampleEmployees
CREATE TABLE ExampleEmployees
(
	ExampleKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	LastName varchar(50) NOT NULL,
	FirstName varchar(50) NOT NULL,
	BirthDate date NULL
);




CREATE OR ALTER PROCEDURE InsertEmployee
	@LastName varchar(50),
	@FirstName varchar(50),
	@BirthDate date = NULL
AS
BEGIN
	INSERT ExampleEmployees (LastName, FirstName, BirthDate) 
	VALUES (@LastName, @FirstName, @BirthDate)
END;

EXEC InsertEmployee 'Durden', 'Tyler'
EXEC InsertEmployee @FirstName = 'Bob', @LastName = 'The Builder', @BirthDate = '06/10/2001'

SELECT * FROM ExampleEmployees

CREATE OR ALTER PROCEDURE InsertEmployee
	@LastName varchar(50),
	@FirstName varchar(50),
	@BirthDate date = NULL
AS
BEGIN
	INSERT ExampleEmployees (LastName, FirstName, BirthDate) 
	OUTPUT inserted.ExampleKey, inserted.BirthDate
	VALUES (@LastName, @FirstName, @BirthDate)
END;

EXEC InsertEmployee 'Reed', 'Russell', '11/5/1975'




CREATE OR ALTER PROCEDURE InsertEmployee
	@LastName varchar(50),
	@FirstName varchar(50),
	@BirthDate date = NULL,
	@ExampleKey int OUTPUT
AS
BEGIN

	INSERT ExampleEmployees (LastName, FirstName, BirthDate) 
	VALUES (@LastName, @FirstName, @BirthDate)
	SET @ExampleKey = SCOPE_IDENTITY()  --Gets the most recent identity from this session
	--Might find examples that use @@IDENTITY....
END;


DECLARE @MyOutput int
EXEC InsertEmployee @LastName = 'Reed', @FirstName = 'Braxton', 
	@BirthDate = '6/15/1998', @ExampleKey = @MyOutput OUTPUT  
	--Opposite order you might expect
PRINT @MyOutput


SELECT * FROM ExampleEmployees







/* A smarter insert */
CREATE OR ALTER PROCEDURE InsertEmployee
	@LastName varchar(50),
	@FirstName varchar(50),
	@BirthDate date = NULL,
	@ExampleKey int OUTPUT
AS
BEGIN
	DECLARE @DoYouExist int = 0

	SELECT
		@DoYouExist = COUNT(EE.ExampleKey)

	FROM
		ExampleEmployees EE

	WHERE
		EE.LastName = @LastName
		AND
		EE.FirstName = @FirstName
		AND
		EE.BirthDate = @BirthDate

	IF (@DoYouExist = 0)
		BEGIN
			INSERT ExampleEmployees (LastName, FirstName, BirthDate) 
			VALUES (@LastName, @FirstName, @BirthDate)
			SET @ExampleKey = SCOPE_IDENTITY()  --Gets the most recent identity from this session
		END
	ELSE
		BEGIN
			SET @ExampleKey = NULL
		END

END;



DECLARE @MyOutput int
EXEC InsertEmployee 'Reed', 'Madison', 
	'9/15/2002', @ExampleKey = @MyOutput OUTPUT  --Opposite order you might expect

IF (@MyOutput IS NULL)
	BEGIN
		PRINT 'This employee already exists.  Insert failed'
	END
ELSE
	BEGIN
		PRINT CONCAT('Employee inserted successfully.  Key value returned', @MyOutput)
	END



ALTER PROCEDURE OutPutTest1
	@SomeValue int,
	@YourValue int OUTPUT
AS
	SET @YourValue = @SomeValue + 1

	RETURN @YourValue

DECLARE @CaptureOutput int

EXEC OutPutTest1 @SomeValue = 2, @YourValue = @CaptureOutput OUTPUT
SELECT @CaptureOutput
	

SELECT * FROM rreed_Employees
SELECT * FROM rreed_Departments

ALTER PROCEDURE NewDepartment
	@departmentName varchar(255),
	@ManagerEmployeeKey int,
	@departmentKey int OUTPUT
AS
INSERT rreed_Departments (DepartmentName,ResponsibleEmployeeKey)
	VALUES (@departmentName, @ManagerEmployeeKey)

--SET @departmentKey = @@IDENTITY  --Don't use this one
SET @departmentKey = SCOPE_IDENTITY()
--OR
--SET @departmentKey = IDENT_CURRENT('rreed_Departments')
--SELECT
--	@departmentKey = DepartmentKey
--FROM
--	rreed_departments
--WHERE
--	departmentName = @departmentName
--	AND
--	responsibleEmployeeKey = @ManagerEmployeeKey

DECLARE @NewDepartmentKey int
EXEC NewDepartment 'Human Resources', '1', @departmentKey = @NewDepartmentKey OUTPUT
SELECT @NewDepartmentKey

BEGIN TRY
	SELECT 1/0
END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER(),
		ERROR_MESSAGE(),
		ERROR_SEVERITY(),
		ERROR_LINE(),
		ERROR_STATE()
END CATCH
SELECT * FROM rreed_Departments

BEGIN TRANSACTION
DECLARE @NewDepartmentKey int
EXEC NewDepartment 'Finance', '1', @departmentKey = @NewDepartmentKey OUTPUT
SELECT @NewDepartmentKey
	


ROLLBACK

COMMIT

BEGIN TRANSACTION
BEGIN TRY
	DECLARE @NewDepartmentKey int
	EXEC NewDepartment 'Employee Satisfaction', '1', @departmentKey = @NewDepartmentKey OUTPUT
	SELECT @NewDepartmentKey
	SELECT 1/0
END TRY
BEGIN CATCH
	ROLLBACK
	--THROW
END CATCH
PRINT @@TRANCOUNT
IF @@TRANCOUNT > 0
BEGIN
	COMMIT
END

SELECT * FROM rreed_departments



