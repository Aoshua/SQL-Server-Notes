/*
	Question #1: Create a view that generates one record per invoice.  Each
	line should have a total of all invoice lines (using extended price),
	the year that the invoice was created in, the invoice id, the customer id
	and the customer name.

	Use the view to return the top 3 largest invoices for customerID 1 and 401, in the
	year 2014.  You should get 6 rows back, one for Tailspin Toys with an invoice
	total of $23,156.98.

	You will need to submit the script to generate your view, then a second query
	that returns the desired results.
*/
SELECT * 
FROM
(
SELECT
C.CityName,
SP.StateProvinceCode,
ROW_NUMBER() OVER (PARTITION BY SP.StateProvinceCode ORDER BY C.CityName DESC) AS [RowNumber]
FROM
Application.Cities AS C
INNER JOIN Application.StateProvinces SP ON C.StateProvinceID = SP.StateProvinceID
WHERE SP.StateProvinceCode IN ('UT', 'WA')
) AS X
WHERE X.RowNumber IN (1, 2)


GO
Alter VIEW View_Invoices AS
	SELECT 
		SUM(IL.ExtendedPrice) AS [TotalExtendedPrice],
		I.InvoiceDate,
		I.InvoiceID,
		C.CustomerID,
		C.CustomerName
	FROM
		Sales.Invoices I 
		INNER JOIN Sales.InvoiceLines IL ON I.InvoiceID = IL.InvoiceID
		INNER JOIN Sales.Customers C ON C.CustomerID = I.CustomerID
	GROUP BY
		I.InvoiceDate,
		I.InvoiceID,
		C.CustomerID,
		C.CustomerName
GO
SELECT 
	*
FROM
(
	SELECT
		TOP 6
		[TotalExtendedPrice],
		InvoiceDate,
		InvoiceID,
		CustomerID,
		CustomerName,
		ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY CustomerID) AS [RowNumber]
	FROM
		View_Invoices
	WHERE 
		CustomerID IN (1, 401)
		AND
		InvoiceDate LIKE '%2014%'
	ORDER BY
		TotalExtendedPrice DESC
) AS T

/*
	Question #2: Write a check constraint for the table defined below that
	restricts ItemCost to be some value between $0.01 and $999,999.99.

	Write two inserts for the table above - one that falls in the approved
	range, one that does not.  

*/
CREATE TABLE CS3550FinalSpring2019_Table1
(
	MyKey int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ItemCost money NOT NULL,
	ItemDescription varchar(255) NOT NULL,
	CreatedOn smalldatetime DEFAULT(GETDATE()),
	UpdatedOn smalldatetime DEFAULT(GETDATE()),
	Active bit DEFAULT(1)
)

ALTER TABLE CS3550FinalSpring2019_Table1
ADD CHECK (ItemCost > 0.01 AND ItemCost < 1000000)

INSERT INTO CS3550FinalSpring2019_Table1 
	(ItemCost, ItemDescription, CreatedOn, UpdatedOn, Active)
	VALUES (0.2, 'Dark Souls III', NULL, NULL, 1)

INSERT INTO CS3550FinalSpring2019_Table1 
	(ItemCost, ItemDescription, CreatedOn, UpdatedOn, Active)
	VALUES (1000000, 'Dark Souls I', NULL, NULL, 0)

/* 
	Write a trigger that prevents deletes from the finals table
		as defined above.
	Your trigger should instead update the active bit to 0.  Make sure your
	trigger works on multiple statements (not just a single row delete).

	Write an insert statement that adds three records to the table.  Then write
	a single delete statement that removes two of the three records (your
	choice on which two).  Finally, add a select statement to validate
	your trigger worked, returning all columns and records for the table.

*/
GO
CREATE OR ALTER TRIGGER InsteadOfDeleteFinal
ON CS3550FinalSpring2019_Table1
INSTEAD OF DELETE
AS
BEGIN
	UPDATE CS3550FinalSpring2019_Table1
	SET Active = 0
	FROM CS3550FinalSpring2019_Table1 AS O JOIN deleted AS D ON O.MyKey = D.MyKey
END

INSERT INTO CS3550FinalSpring2019_Table1 
	(ItemCost, ItemDescription, CreatedOn, UpdatedOn, Active)
	VALUES (15.45, 'Game1', GETDATE(), GETDATE(), 1),
			(30.56, 'Game2', GETDATE(), GETDATE(), 1),
			(59.99, 'Game3', GETDATE(), GETDATE(), 1)

DELETE FROM CS3550FinalSpring2019_Table1 WHERE MyKey IN (1, 2)

SELECT * FROM CS3550FinalSpring2019_Table1

/*	
	Question #4: Write a trigger that updates the "UpdatedOn" column
	after someone updates any value in the above finals table.  Again,
	make sure your trigger will handle updates to multiple records...

	Write an insert statement that inserts two new rows.  Then write an
	update statement that increases the cost for each by 10%.  Last,
	write a select statement that returns all the rows and validate
	that the create date was updated for each row.  

*/
GO
CREATE OR ALTER TRIGGER InsteadOfUpdateFinal
ON CS3550FinalSpring2019_Table1
INSTEAD OF UPDATE
AS
BEGIN
	UPDATE CS3550FinalSpring2019_Table1
	SET UpdatedOn = GETDATE()
	FROM CS3550FinalSpring2019_Table1 AS O JOIN inserted AS U ON O.MyKey = U.MyKey
END

INSERT INTO CS3550FinalSpring2019_Table1 
	(ItemCost, ItemDescription)
	VALUES (15.45, 'Game4'),
			(30.56, 'Game5')

UPDATE CS3550FinalSpring2019_Table1
SET  ItemCost = ItemCost + (ItemCost * 0.1)
WHERE MyKey IN (4, 5)

SELECT * FROM CS3550FinalSpring2019_Table1

/* 
	Question #5: Write a stored procedure to add rows to the above
	finals table.  Rules you need to consider - 
	- Verify that an item with the same name is not already in the table.
		If there is, return -2 and print out a message for the problem
	- Check for errors when you insert and gracefully handle the 
		problem by returning a value of -1 and printing out a message
		of the problem.

	Write a script to call your stored procedure three times - one with a
		bad price, one with a duplicated description, and one that works.
		Make sure to capture the error code and print it to the screen.
	ERROR_MESSAGE()
*/
GO -- output variable return = set output
CREATE OR ALTER PROCEDURE dbo.ADD_TO_FINALS_TABLE
	@Item_Cost money,
	@Item_Description varchar(255),
	@Code int OUTPUT 
	--Only these values because the rest have reasonable defaults
AS
BEGIN
	IF ( SELECT COUNT(*) FROM CS3550FinalSpring2019_Table1 WHERE ItemDescription = @Item_Description ) = 0
		BEGIN TRY
			INSERT CS3550FinalSpring2019_Table1 (ItemCost, ItemDescription)
			VALUES (@Item_Cost, @Item_Description)
		END TRY
		BEGIN CATCH
			PRINT 'An error occured while inserting the values.'
			SET @Code = -1 --RETURN -1
		END CATCH			
	ELSE
		BEGIN
			PRINT 'There is already an item with this description.'
			SET @Code = -2 --RETURN -2
		END
	PRINT @Code
END

DECLARE @InputCode int = 0
EXEC ADD_TO_FINALS_TABLE 10000000, 'AnotherTitle', @InputCode
EXEC ADD_TO_FINALS_TABLE 56.50, 'Game4', @InputCode
EXEC ADD_TO_FINALS_TABLE 14.50, 'YetAnotherGame', @InputCode

/* 
	Question #6: Write a function that takes a dollar amount and a tax rate as inputs
	and returns the price with tax applied to it.

	Write a query that returns all invoices for all customers in Utah.  Use your
	function to calculate the sales tax for each invoice, using 7.25%.  The below
	query is a starting point for this.  You can use your view from above to get the
	invoice totals or can write it from scratch.  

	You are required to turn in the script for the function, along with the query
	that returns invoices for Utah customers.
*/

GO
CREATE OR ALTER FUNCTION After_Tax_Final(
	@dolarAmount money,
	@taxRate decimal(10, 5) -- Takes sales tax in form 7.25 NOT 0.0725
) RETURNS money
AS
BEGIN
	RETURN @dolarAmount + (@dolarAmount * (@taxRate / 100.0))
END
GO

SELECT
	C.CustomerID,
	ROUND(dbo.After_Tax_Final (TotalExtendedPrice, 7.25), 2) -- Round to 2 decimal places for money
FROM 
          Sales.Customers C
          INNER JOIN Application.Cities CI ON C.PostalCityID = CI.CityID
          INNER JOIN Application.StateProvinces SP ON SP.StateProvinceID = CI.StateProvinceID
		  INNER JOIN View_Invoices AS V ON V.CustomerID = C.CustomerID
WHERE
          SP.StateProvinceCode = 'UT'


/* 
	Question #7: Write a query that returns yearly sales (2013, 2014, 2015, 2016) and
	a total for all years for each Color in the Warehouse.Colors table.  
	You'll use the Sales.Invoices, Sales.InvoiceLines, Warehouse.StockItems, 
	and Warehouse.Colors tables.  Use the Extended price in the InvoiceLines table
	for the dollar values and InvoiceDate in the Invoices table for the year.

	Sort your final results on largest to smallest total sales.  You should get
	36 rows back.  Blue had the most sales with 41,289,464.30. Red had  
	1,505,240.75 of sales in 2014.
*/

SELECT
	C.ColorName,
	ISNULL(SUM(CASE WHEN I.InvoiceDate LIKE '%2013%' THEN IL.ExtendedPrice END), 0) AS [2013 Sales],
	ISNULL(SUM(CASE WHEN I.InvoiceDate LIKE '%2014%' THEN IL.ExtendedPrice END), 0) AS [2014 Sales],
	ISNULL(SUM(CASE WHEN I.InvoiceDate LIKE '%2015%' THEN IL.ExtendedPrice END), 0) AS [2015 Sales],
	ISNULL(SUM(CASE WHEN I.InvoiceDate LIKE '%2016%' THEN IL.ExtendedPrice END), 0) AS [2016 Sales],
	ISNULL(SUM(IL.ExtendedPrice), 0) AS [Total Sales]
FROM
	Warehouse.Colors AS C
	LEFT JOIN Warehouse.StockItems AS SI ON SI.ColorID = C.ColorID
	LEFT JOIN Sales.InvoiceLines AS IL ON IL.StockItemID = SI.StockItemID
	LEFT JOIN Sales.Invoices AS I ON I.InvoiceID = IL.InvoiceID
GROUP BY
	C.ColorName
ORDER BY 
	[Total Sales] DESC

/*
	Question #8: Create a view that returns all employees from the Application.People
	table (isEmployee = 1).  Make sure your view does the following:
		- Return a last name and first name column, leveraging the full name
			column to get the values.
		- Fix the LogonName to exclude @wideworldimporters.com
		- Pull out title and hire date from the JSON string, using the built
			in functions (no string parsing)
		- Add a column for tenure that is calculated based on the difference
			of days between the current date and their hire date
			divided by 365.0 (you should get a decimal value that represents years)
		- Include their email address, preferred name, personId also.
*/
SELECT 
	SUBSTRING(FullName, CHARINDEX(' ', FullName) + 1, LEN(FullName) - CHARINDEX(' ', FullName)) AS [Last Name],
	SUBSTRING(FullName, 1, CHARINDEX(' ', FullName) - 1) AS [First Name],
	SUBSTRING(LogonName, 1, CHARINDEX('@', LogonName) - 1) AS [Logon Name],
	JSON_VALUE(CustomFields, '$.Title') AS [Title],
	CONVERT(datetime2, JSON_VALUE(CustomFields, '$.HireDate')) AS HireDate,
	 DATEDIFF(day, 
	 	CONVERT(datetime2, JSON_VALUE(CustomFields, '$.HireDate'))
	 	, GETDATE()) / 365.0 AS [Tenture],
	EmailAddress,
	PreferredName,
	PersonID
FROM 
	Application.People
WHERE
	IsEmployee = 1

SELECT * FROM Application.People WHERE IsEmployee = 1


/* 
	Question #9: Write T-SQL that simulates the typical random drop rates of 
	rare items in games.  First, you'll need to understand how to generate a random
	number - a good stackoverflow post - 
	https://stackoverflow.com/questions/7878287/generate-random-int-value-from-3-to-6

	Here are the rules you need to simulate:

	- generate a number between 1 and 1000
	- values between 1 and 915 means a common item dropped
	- values between 916 and 995 means a rare item dropped
	- values between 996 and 1000 means an epic item dropped

	You will write a script that simulates 10,000 item drops.  You will store
	the roll number, the generated roll value and item type to a table variable.
	When done, write a query that returns how many of each item was rolled 
	and what percentage of the rolls it represents.  

	Run your script three times, take a screen shot of each result and submit them
	 with the script for credit.

*/
DECLARE @DropResults TABLE (RollNumber int, RolledValue int, ItemType varchar(20))

DECLARE @Loop_Counter int = 1
DECLARE @RollValue int
DECLARE @Rarity varchar(20)
WHILE @Loop_Counter < 1000
BEGIN
	SET @RollValue = ABS(CHECKSUM(NEWID()) % 1000) + 1
	IF @RollValue > 0 AND @RollValue < 916
		SET @Rarity = 'Common'
	ELSE IF @RollValue >= 916 AND @RollValue < 996
		SET @Rarity = 'Rare'
	ELSE
		SET @Rarity = 'Epic'

	INSERT INTO @DropResults (RollNumber, RolledValue, ItemType)
	VALUES (@Loop_Counter, @RollValue, @Rarity)

	SET @Loop_Counter = @Loop_Counter + 1
END
PRINT ABS(CHECKSUM(NEWID()) % 1000) + 1

SELECT * FROM @DropResults