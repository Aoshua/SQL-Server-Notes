/* Dynamic Queries */




/* Execute a sql command that concats the variable in */

DECLARE @sqlStatement varchar(max)
DECLARE @state varchar(50) = 'Utah'

SET @sqlStatement = '
SELECT
	C.CityID,
	C.CityName,
	SP.StateProvinceID,
	SP.StateProvinceName,
	SP.StateProvinceCode
FROM
	Application.Cities C
	INNER JOIN Application.StateProvinces SP ON C.StateProvinceID = SP.StateProvinceID

WHERE
	SP.StateProvinceName = ''' + @state + ''''

PRINT @sqlStatement

EXECUTE (@sqlStatement)








/* A slightly different approach - allows you to pass in parameters/variables into 
	your dynamic string
	*/


DECLARE @sqlStatement nvarchar(max)
--DECLARE @state varchar(50) = 'Utah'

SET @sqlStatement = '
SELECT
	C.CityID,
	C.CityName,
	SP.StateProvinceID,
	SP.StateProvinceName,
	SP.StateProvinceCode
FROM
	Application.Cities C
	INNER JOIN Application.StateProvinces SP ON C.StateProvinceID = SP.StateProvinceID

WHERE
	SP.StateProvinceName = @state
'

PRINT @sqlStatement

EXECUTE sp_executesql @sqlStatement, N'@state nvarchar(50)', @state = 'Utah'

--Can have multiple variables - declare them in the first statement like N'@var1 int, @var2 int', @var1 = 100, @var2 = 200













/* SQL Injection */










DECLARE @findEmployees varchar(max)
DECLARE @searchString varchar(255) = 'Archer'

SET @findEmployees = 
	'SELECT * FROM Application.People WHERE fullname like ''%' 
		+ @searchString + '%'''

PRINT @findEmployees
EXECUTE (@findEmployees)












CREATE TABLE WillBeDeleted
(
	WillBeDeletedKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SomeValue varchar(255)
)

INSERT WillBeDeleted (SomeValue) VALUES ('Yankees')
INSERT WillBeDeleted (SomeValue) VALUES ('Giants')

SELECT * FROM WillBeDeleted


DECLARE @Query varchar(max)
DECLARE @SearchString varchar(255)
--SET @searchString = 'Yank'';SELECT * FROM sys.tables;--'
--SET @searchString = 'Gia'

SET @searchString = 'Gia'';DROP TABLE WillBeDeleted;--'
SET @Query = 'SELECT * FROM WillBeDeleted WHERE SomeValue LIKE ''%' 
	+ @searchString + '%'''


PRINT @Query
EXECUTE (@Query)

SELECT * FROM WillBeDeleted





















DECLARE @SearchString nvarchar(255)
DECLARE @Query nvarchar(max)

SET @Query = N'SELECT * FROM WillBeDeleted WHERE SomeValue LIKE ''%'' + @searchString + ''%'''

EXEC sp_executesql @Query, N'@searchString varchar(255)', @searchString = 'Yank'';SELECT * FROM sys.tables;--'
--EXEC sp_executesql @Query, N'@searchString varchar(255)', @searchString = N'Gia'
PRINT @query

--



DECLARE @query nvarchar(max)
DECLARE @tableName nvarchar(255) = 'People'
DECLARE @schemaName nvarchar(255) = 'Application'


SET @Query = 'SELECT * FROM ' + @schemaName + '.' + @tableName

EXECUTE (@query)










DECLARE @query nvarchar(max)
DECLARE @tableName nvarchar(255) = 'People;SELECT * FROM sys.tables;--'
DECLARE @schemaName nvarchar(255) = 'Application'


SET @Query = 'SELECT * FROM ' + @schemaName + '.' + @tableName

EXECUTE (@query)








DECLARE @query nvarchar(max)
DECLARE @tableName nvarchar(255) = 'People;SELECT * FROM sys.tables;--'
DECLARE @schemaName nvarchar(255) = 'Application'


SET @Query = 'SELECT * FROM ' + QUOTENAME(@schemaName) + '.' + QUOTENAME(@tableName)
PRINT @Query

EXECUTE (@query)








http://blogs.lobsterpot.com.au/2015/02/10/sql-injection-the-golden-rule/








https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-2017



SELECT
	*
FROM
	sys.objects

SELECT
	T.name [TableName],
	S.name [Schema],
	C.name [Column] 
FROM 
	sys.tables T
	INNER JOIN sys.schemas S ON T.schema_id = S.schema_id
	INNER JOIN sys.columns C ON C.object_id = T.object_id

ORDER BY
	T.name,
	C.name




DECLARE @Temp TABLE (TempKey int IDENTITY(1,1), ColumnName varchar(255), Processed bit DEFAULT(0))

INSERT @Temp (ColumnName)
SELECT
--	T.name [TableName],
--	S.name [Schema],
	C.name [Column] 
FROM 
	sys.tables T
	INNER JOIN sys.schemas S ON T.schema_id = S.schema_id
	INNER JOIN sys.columns C ON C.object_id = T.object_id

WHERE
	T.name = 'People'

DECLARE @ColumnName varchar(255)
DECLARE @TempKey int
DECLARE @SqlCommand varchar(max)

SET @SqlCommand = 'SELECT'

WHILE (SELECT COUNT(*) FROM @Temp WHERE Processed = 0) > 0
BEGIN
	SELECT
		TOP 1
		@ColumnName = ColumnName,
		@TempKey = TempKey
	FROM
		@Temp
	WHERE
		Processed = 0

	SET @SqlCommand = @SqlCommand + '
		' + @ColumnName + ','

	UPDATE @Temp SET Processed = 1 WHERE TempKey = @TempKey

END

SET @SqlCommand = LEFT(@SqlCommand, LEN(@SqlCommand) - 1)
SET @SqlCommand = @SqlCommand + '
FROM
	Application.People'

PRINT @SqlCommand
EXECUTE (@SqlCommand)







/* Cursors - ick!*/

DECLARE MyFirstCursor CURSOR
FOR
SELECT TOP 5
	P.PersonID,
	P.EmailAddress,
	P.FullName
FROM
	Application.People P

OPEN MyFirstCursor

FETCH NEXT FROM MyFirstCursor
CLOSE MyFirstCursor
DEALLOCATE MyFirstCursor

/*
Default cursor type is a forward only cursor.
Allows you to go through the records one at a time
but never backwards.

Declare the cursor, feeding it a query.
Open it, then move through it as needed.  Once done
	close and deallocate it.  You have to clean up
	after yourself.
*/

DECLARE MySecondCursor SCROLL CURSOR
FOR
SELECT TOP 5
	P.PersonID,
	P.EmailAddress,
	P.FullName
FROM
	Application.People P

OPEN MySecondCursor

FETCH NEXT FROM MySecondCursor
FETCH PRIOR FROM MySecondCursor

CLOSE MySecondCursor
DEALLOCATE MySecondCursor






ALTER VIEW SalesTotals WITH SCHEMABINDING
AS
SELECT
	I.InvoiceId,
	YEAR(I.InvoiceDate) [YearOfInvoice],
	SUM(IL.ExtendedPrice) [InvoiceTotal]
FROM
	Sales.Invoices AS I
	INNER JOIN Sales.InvoiceLines AS IL ON I.InvoiceID = IL.InvoiceID

GROUP BY
	I.InvoiceID,
	YEAR(I.InvoiceDate)




SELECT
	*
FROM
	SalesTotals AS ST
	INNER JOIN Sales.Invoices AS I ON ST.InvoiceID = I.InvoiceID



/*
Types of constraints
 - NOT NULL
 - CHECK
 - UNIQUE
 - PRIMARY KEY (a unique constraint that doesn't allow NULL)
 - FOREIGN KEY (a check constraint that checks another table)
*/

CREATE TABLE SomeConstraints
(
	SomeConstraintsKey int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	SomeNumber int,
	SomeDate datetime NOT NULL DEFAULT(GETDATE()),
	SomeValue varchar(255),
	SomeUniqueNumber tinyint,
	CONSTRAINT SomeNumberSmall CHECK (SomeNumber BETWEEN 0 and 100),
	CONSTRAINT SomeUniqueNumberCheck UNIQUE (SomeUniqueNumber)
)

INSERT SomeConstraints (SomeNumber, SomeUniqueNumber) VALUES (1, 1)
INSERT SomeConstraints (SomeNumber, SomeUniqueNumber) VALUES (98, 2)
INSERT SomeConstraints (SomeNumber, SomeUniqueNumber) VALUES (99, 2)

SELECT * FROM SomeConstraints
INSERT SomeConstraints (SomeNumber, SomeUniqueNumber) VALUES (101, 3)
