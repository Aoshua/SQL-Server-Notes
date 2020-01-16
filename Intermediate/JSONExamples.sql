/* ------------------------------------
	JSON - JAVASCRIPT OBJECT NOTATION:
*/ ------------------------------------

-- A better option than XML.
-- SQL Server has a few built in functions to output or parse JSON 

SELECT TOP 10
	O.OrderID [OrderKey],
	O.OrderDate[DateofOrder],
	OL.Quantity [OrderDetail.Quantity],
	OL.UnitPrice [OrderDetail.Price]
FROM
	Sales.Orders O
	INNER JOIN Sales.OrderLines OL ON O.OrderID = OL.OrderID

FOR JSON PATH
--FOR JSON AUTO

-------

SELECT TOP 5
	C.CustomerID [Customer.CustomerKey],
	C.CustomerName [Customer.BusinessName],
	PC.PersonID [Customer.PrimaryContact.PersonKey],
	PC.FullName [Customer.PrimaryContact.Name],
	PC.EmailAddress [Customer.PrimaryContact.Email],
	AC.PersonID [Customer.AlternateContact.PersonKey],
	AC.FullName [Customer.AlternateContact.Name],
	AC.EmailAddress [Customer.AlternateContact.Email]

FROM
	Sales.Customers C
	INNER JOIN Application.People PC 
		ON C.PrimaryContactPersonID = PC.PersonID
	INNER JOIN Application.People AC
		ON C.AlternateContactPersonID = AC.PersonID

FOR JSON PATH

-------

SELECT TOP 5
	C.CustomerID ,
	C.CustomerName ,
	PC.PersonID,
	PC.FullName ,
	PC.EmailAddress ,
	AC.PersonID ,
	AC.FullName ,
	AC.EmailAddress 
FROM
	Sales.Customers C
	INNER JOIN Application.People PC 
		ON C.PrimaryContactPersonID = PC.PersonID
	INNER JOIN Application.People AC
		ON C.AlternateContactPersonID = AC.PersonID

FOR JSON AUTO

-------

SELECT
	*
FROM
	Application.People AS P

-------

SELECT
	P.CustomFields,
	P.PersonID,
	P.FullName,
	JSON_VALUE(P.CustomFields, '$.Title') [Title],
	JSON_VALUE(P.CustomFields, '$.title') [NotGoingToWork],
	JSON_VALUE(P.CustomFields, '$.OtherLanguages') [AlsoNotGoingToWork],
	JSON_QUERY(P.CustomFields, '$.OtherLanguages') [LanguageArray],
	JSON_QUERY(P.CustomFields, '$.Title') [Nope]
FROM
	Application.People P

WHERE
	P.IsEmployee = 1

-------

/* 
	CROSS APPLY - takes a table result - from a function or
	anything that creates a table and applies it to each
	row of the previous table
*/
SELECT
	*
FROM
	Application.People P
	CROSS APPLY
	(
		SELECT
			NEWID() [GUID]  -- system function to create GUID
	) X

WHERE
	P.IsEmployee = 1

-------

	/* simple OPENJSON call - pulls out the JSON array
	into default key/value columns  */
SELECT
	P.PersonID, 
	P.FullName,
	P.CustomFields,
	X.*
FROM
	Application.People P
	OUTER APPLY OPENJSON(P.CustomFields, '$.OtherLanguages') X

WHERE
	P.IsEmployee = 1

/* OPENJSON with WITH statement - gives you more control
 on how the data is pulled from your JSON string
 */

 -------

SELECT
	P.PersonID, 
	P.FullName,
	P.CustomFields,
	X.*,
	DATEADD(yyyy, 1, X.HiredOn),
	Y.*
FROM
	Application.People P
	OUTER APPLY OPENJSON(P.CustomFields)
		WITH
		(
			JobTitle varchar(50) '$.Title',
			TerritoryCovered varchar(50) '$.PrimarySalesTerritory',
			LanguageSpoken nvarchar(max) '$.OtherLanguages' AS JSON,
			HiredOn date '$.HireDate'
		)
	AS X
	OUTER APPLY OPENJSON(X.LanguageSpoken)
		WITH
		(
			MyNameForLanguagesSpoken varchar(50) '$'
		)
	AS Y

WHERE
	P.IsEmployee = 1