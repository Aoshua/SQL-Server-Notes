/* ------------------------------------------------
	CONCEPT - DETERMINISTIC VS. NON-DETERMINISTIC:
*/ ------------------------------------------------

SELECT
	RAND(),
	NEWID(),
	GETDATE(),
	P.PersonID,
	P.FullName

FROM
	Application.People AS P

------

/* 
	With SQL Server, a non-deterministic function will only get executed 
	once for the entire statement, with one exception (newid())

	SQL Server will try to figure out if your function is deterministic
	or not and will treat appropriately.


	Why do you care?  Only deterministic functions can be used in indexed 
	views and computed columns.
*/

CREATE FUNCTION AddNumbers (@num1 int, @num2 int)

RETURNS int
AS
BEGIN
	
	RETURN @num1 + @num2

END

-------

SELECT
	dbo.AddNumbers(1,2)

-------

SELECT TOP 100
	dbo.AddNumbers(IL.StockItemID, IL.Quantity),
	*
FROM
	Sales.InvoiceLines IL

-------

CREATE FUNCTION CalculateExtendedPrice
(
	@quantity int,
	@unitPrice money,
	@taxRate decimal (18,3)
)

RETURNS decimal(18,2)AS
BEGIN

	RETURN (@quantity * @unitPrice) + ((@quantity * @unitPrice) * (@taxRate /100))
END

-------

SELECT TOP 100
	dbo.CalculateExtendedPrice (IL.Quantity, IL.UnitPrice, IL.TaxRate) [OurExtendedPrice],
	ExtendedPrice
FROM
	Sales.InvoiceLines IL

-------

/* Functions
 - Scalar functions
 - table valued functions

 */

/* 
Scalar Function - returns a single value
 - can be used anywhere a built-in function can be used
 - Run for each row in the result set (performance issues)

 */

-------

/* Example from red-gate */

/* Scalar functions can be useful in constraints... */


CREATE TABLE dbo.Salaries
    (
      EmployeeID INT NOT NULL ,
      BaseSalary MONEY NOT NULL ,
      Bonus MONEY NULL
    ) ;
 
ALTER TABLE dbo.Salaries
ADD CONSTRAINT CheckMaxBonus 
CHECK ((COALESCE(Bonus, 0) * 4) <= BaseSalary) ;


CREATE FUNCTION dbo.SalaryWithinBounds ( @Salary MONEY )
RETURNS BIT
AS 
    BEGIN
        DECLARE @r_val AS BIT ;
        DECLARE @MinSalary AS MONEY ;
 
        SELECT  @MinSalary = MIN(BaseSalary)
        FROM    dbo.Salaries
 
        IF ( @MinSalary * 10 ) > @Salary 
            SET @r_val = 1
        ELSE 
            SET @r_val = 0
 
        RETURN @r_val ;
    END 
GO
 
ALTER TABLE dbo.Salaries
ADD CONSTRAINT CheckMaxSalary
     CHECK (dbo.SalaryWithinBounds(BaseSalary) = 1) ;
GO
 
/* This insert succeeds */
INSERT  INTO dbo.Salaries
        ( EmployeeID, BaseSalary, Bonus )
VALUES  ( 5, 1000, 0 ) ;
/* This insert will fail */
INSERT  INTO dbo.Salaries
        ( EmployeeID, BaseSalary, Bonus )
VALUES  ( 6, 100000000, 50000 ) ;

/* ---------------------------------
	TABLE VALUED FUNCTIONS (TVF'S):
*/ ---------------------------------

CREATE OR ALTER FUNCTION dbo.StockItemList
(
	@StockItem varchar(255)
)
RETURNS TABLE
AS
RETURN

	SELECT
		*
	FROM
		Warehouse.StockItems AS SI
	WHERE
		SI.StockItemName like '%'+ @StockItem + '%'

SELECT * FROM dbo.StockItemList('USB')

-------

CREATE FUNCTION InvoicesByProduct
(
	@stockItemID int
)
RETURNS @tempTable TABLE 
(
	InvoiceID int,
	Quantity int,
	UnitPrice decimal(18,2)
)
AS
BEGIN
	
	INSERT @tempTable (InvoiceID, Quantity, UnitPrice)
	SELECT
		I.InvoiceID,
		Quantity,
		UnitPrice
	FROM
		Sales.Invoices I
		INNER JOIN Sales.InvoiceLines IL ON I.InvoiceID = IL.InvoiceID
	WHERE
		IL.StockItemID = @stockItemID

	RETURN
END

SELECT
	*
FROM
	dbo.InvoicesByProduct(15) X
	INNER JOIN Sales.Invoices I ON X.invoiceID = I.InvoiceID 
	INNER JOIN Sales.InvoiceLines IL ON I.InvoiceID = IL.InvoiceID


-- Helpful reference:
https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-functions-the-basics/