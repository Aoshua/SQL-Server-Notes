/*
Query #1 - 7 points

The warehouse team needs to validate the list of items for 
	the company "Northwind Electric Cars".  They'd like you to write a query to
	extract a list of items including the stockItemId, name (supplier and stock), 
	size, unit price, and recommended price.  You'll need the Suppliers
	table in the Purchasing schema and the StockItems table in the 
	Warehouse schema.  

	Order the final list based on the stock item name (alphabetic - a to z)

Results will include 18 rows and 6 columns.  The top row will be a 
	"RC big wheel monster truck with remote control (Black) 1/50 scale" item
*/
SELECT 
	StockItemID,
	StockItemName,
	SupplierName,
	Size,
	UnitPrice,
	RecommendedRetailPrice
FROM
	Purchasing.Suppliers AS S
	JOIN Warehouse.StockItems AS SI ON S.SupplierID = SI.SupplierID
WHERE 
	S.SupplierName = 'Northwind Electric Cars'
ORDER BY
	SI.StockItemName




/*
Question #2 - 10 points

The marketing team wants a list of all the products for all customers that 
	they can include in an email.  You'll need information from the StockItems and 
	Colors tables in the Warehouse schema, and the Suppliers table in the Purchasing
	schema.  
	Include the Stock Item ID, name, Color, brand, size, lead time, unit price, and Supplier Name.
	For things that do not have a color, use "unknown" as the return value.  

Sort the final results by supplier, unit price (lowest to highest) and Stock Item name.

This query will return 227 rows.  99 items will have an unknown color

*/
SELECT
	StockItemID,
	StockItemName,
	CASE WHEN ColorName IS NULL THEN 'Unknown' ELSE ColorName END,
	Brand,
	Size,
	LeadTimeDays,
	UnitPrice,
	SupplierName
FROM 
	Warehouse.StockItems AS SI
	LEFT JOIN Warehouse.Colors AS C ON SI.ColorID = C.ColorID
	JOIN Purchasing.Suppliers AS PS ON SI.SupplierID = PS.SupplierID
ORDER BY 
	SupplierName,
	SI.UnitPrice,
	SI.StockItemName

/*
Question #3 - 15 points

Its time for the annual trade show and you want to make sure all
	your suppliers make it to the party.  The marketing team needs
	a list of all your suppliers, their full delivery address, and 
	the name of both the primary and alternate contacts for the 
	supplier.  Order the results by supplier name.

	You'll be using a number of tables - Suppliers from the Purchasing schema
	and the People, Cities, and StateProvinces tables in the Application 
	schema.  The columns to join things up are a bit more tricky -
	 
		- Suppliers to people on the PersonID and the PrimaryContactPersonID
			or AlternateContactPersonID. (DONT USE OR)
		- Cities on CityID to Suppliers on DeliveryCityID
		- StateProvices on StateProvinceID (on both sides)

	Something to keep in mind...  you can join to the same table multiple times
	as long as you give them different aliases.

This query will return 13 rows and 9 columns.  An example to compare to - 

SupplierName		PrimaryContactName	AlternateContactName	DeliveryAddressLine1	DeliveryAddressLine2		DeliveryCityID	CityName	StateProvinceCode	DeliveryPostalCode
A Datum Corporation	Reio Kabin			Oliver Kivi				Suite 10				183838 Southwest Boulevard	38171			Zionsville	IN					46077

*/
SELECT
	SupplierName,	
	(
		SELECT
			FullName
		FROM 
			Application.People AS AP
		WHERE 
			AP.PersonID = PS.PrimaryContactPersonID
	) AS [Primary Contact],
	(
		SELECT
			FullName
		FROM 
			Application.People AS AP
		WHERE 
			AP.PersonID = PS.AlternateContactPersonID
	) AS [Alternative Contact],
	DeliveryAddressLine1, 
	DeliveryAddressLine2,
	DeliveryCityID,
	CityName,
	StateProvinceCode,
	DeliveryPostalCode
FROM
	Purchasing.Suppliers AS PS
	JOIN Application.Cities AS AC ON AC.CityID = PS.DeliveryCityID
	JOIN Application.StateProvinces AS ASP ON AC.StateProvinceID = ASP.StateProvinceID
ORDER BY PS.SupplierName

/*
Question #4 - 8 points

Write a query that returns all employees - 19 rows, using the isEmployee field equal to 1.
Return the personID, their logon name, phone number, and name.

For the name, you need to rearrange the name stored in the FullName column to be in the format:
	
	Reed, Russell (last name a comma, a space, then the first name)

For the phone number, remove all the non-numeric characters and reformat it to look like:

	801.112.2345

For the logon name, concat. the person id to the end of the logon, seperated by
	a space, then a dash, then a space (hudsono@wideworldimporters.com - 3)

Sort the final results based on your new name field, a to z
*/

SELECT
	PersonID,
	(
		SUBSTRING(P.FullName, CHARINDEX(' ', P.FullName) + 1, LEN(P.FullName) - CHARINDEX(' ', P.FullName)) 
		+ ', ' +  
		SUBSTRING(p.FullName, 1, CHARINDEX(' ', P.FullName) - 1)
	) AS [Name],
	(
		P.LogonName + ' - ' + CAST(P.PersonID AS VARCHAR(3))
	) AS [LogonName],
	(
		SUBSTRING(P.PhoneNumber, 2, 3) + '.' + SUBSTRING(P.PhoneNumber, 7, 3) + '.' + SUBSTRING(P.PhoneNumber, 11, 4)
	) AS [PhoneNumber]
	
FROM
	Application.People AS P
WHERE
	P.IsEmployee = 1
ORDER BY
	Name


