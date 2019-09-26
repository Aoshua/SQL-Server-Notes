/*
Question #1: 5 points

Write a query that counts how many invoices are in the system for 
	each year.  You will need only the Sales.Invoices table for this query.
	The year can be determined by the InvoiceDate column.  Sort the final 
	results by the count of invoices, largest to smallest.

You should get 4 rows back.  2015 had 22,250 invoices
*/
SELECT
	YEAR(SI.InvoiceDate) 'Year',
	COUNT(SI.InvoiceDate) 'Sales'	
FROM 
	Sales.Invoices As SI
GROUP BY 
	YEAR(SI.InvoiceDate)
ORDER BY
	COUNT(SI.InvoiceDate) DESC
	
/*
Question #2: 5 points

Write a query that returns the average, min, and max
	quantities for all stock items.  You'll need the 
	Warehouse.StockItems and Sales.InvoiceLines tables.
	They join on the StockItemID column.  Return the 
	StockItemID, StockItem name, and the average, min, 
	and max quantities.  Sort the final result by the 
	average quantity, largest to smallest.

You should get 227 rows.  The "Black and orange fragile despatch tape 48mmx75m"
	stock item has an average quanity of 199, a minimum of 36, and a maximum
	of 360.
*/
SELECT
	WSI.StockItemID,
	WSI.StockItemName,
	AVG(SIL.Quantity) AS 'Average Quantity',
	MIN(SIL.Quantity) AS 'Minimum Quantity',
	MAX(SIL.Quantity) AS 'Maximum Quantity'
FROM
	Warehouse.StockItems AS WSI
	JOIN 
	Sales.InvoiceLines AS SIL ON WSI.StockItemID = SIL.StockItemID
GROUP BY
	WSI.StockItemID,
	WSI.StockItemName
ORDER BY
	AVG(SIL.Quantity) DESC

/* 
Question #3: 10 points

Write a query that shows all colors in the Warehouse.Colors table
	and the number of StockItems (in Warehouse.StockItems) that have the color.  Return the 
	color ID, the Color Name, and the count of stock items.  Order the final results by
	the count, largest to smallest.

You should get 36 rows back.  Black has 51 stock items, Hot Pink has 0.  The two
	tables can be joined on the ColorID column
*/
SELECT
	WC.ColorID,
	WC.ColorName,
	COUNT(WSI.StockItemID) AS 'Number of Items'
FROM
	Warehouse.Colors AS WC
	LEFT JOIN
	Warehouse.StockItems AS WSI ON WC.ColorID = WSI.ColorID
GROUP BY 
	WC.ColorID,
	WC.ColorName
ORDER BY
	COUNT(WSI.StockItemID) DESC

/*
Question #4: 10 points

Write a query to identify any StockItem that has sold more than
	40,000 units in 2015.  You will need the Warehouse.StockItems,
	Sales.Invoices, and Sales.InvoiceLines tables.  Sales.Invoices
	joins to Sales.InvoiceLines on InvoiceID.  Sales.InvoiceLines
	joins to the StockItems table on StockItemID.  You can get the quanity
	sold from the Quantity value in the InvoiceLines table.  The date
	of sale is the InvoiceDate in the Invoices table.

You should get 21 rows back.  The top seller was "Black and orange fragile despatch tape 48mmx75m"
	at 64,224 items sold.  The last item on the list is "Black and orange handle with care despatch tape  48mmx100m"
	at 40,800 items sold
*/
SELECT
	WSI.StockItemID,
	WSI.StockItemName,
	SUM(SIL.Quantity) AS 'Quantity Sold'
FROM
	Warehouse.StockItems AS WSI
	JOIN Sales.InvoiceLines AS SIL ON WSI.StockItemID = SIL.StockItemID
	JOIN Sales.Invoices AS SI ON SIL.InvoiceID = SI.InvoiceID
WHERE
	YEAR(SI.InvoiceDate) = 2015
GROUP BY
	WSI.StockItemID,
	WSI.StockItemName
HAVING 
	SUM(SIL.Quantity) > 40000
ORDER BY
	SUM(SIL.Quantity) DESC

/*
Question #5: 15 points

Write a query that brings back a row for each customer, a count
	of invoices they have, the total extended price of all invoices, 
	the min value, and the max value of the invoice total.  
	To get the total value of an invoice, you have
	to sum up the extended price value in the Sales.InvoiceLines table.
	You will need the Sales.Invoices, Sales.InvoiceLines, and Sales.Customers 
	tables.  The first two join on the InvoiceID column.  Sales.Customers joins
	to Sales.Invoices on the CustomerID.  Order the final results by the 
	count of invoices (largest to smallest), then by the largest invoice (largest
	to smallest).

	You should get 663 rows back.  Bhaavan Rai is the first row with 144 
	invoices.  Their smallest invoice total was 29.90, the largest 20,386.31.  
	Total business with Bhaavan Rai is $369,173.36

	??Are min and max supposed to be of the Extended Price??
*/
SELECT
	C.CustomerID,
	C.CustomerName,
	COUNT(DISTINCT IL.InvoiceID) AS 'Invoice Quantity', 
	SUM(IL.ExtendedPrice) AS 'Total Extended Price',
	MIN(SubQuery.PricePerInvoice) AS 'Min Extended Price', --of column from subquery
	MAX(SubQuery.PricePerInvoice) AS 'Max Extended Price'
FROM
	Sales.Customers AS C
	LEFT JOIN Sales.Invoices AS I ON C.CustomerID = I.CustomerID 
	LEFT JOIN Sales.InvoiceLines AS IL ON I.InvoiceID = IL.InvoiceID
	LEFT JOIN 
		(
			SELECT
				SUM(ExtendedPrice) AS PricePerInvoice,
				InvoiceID
			FROM
				Sales.InvoiceLines
			GROUP BY
				InvoiceID
		) AS [SubQuery] ON IL.InvoiceID = SubQuery.InvoiceID
GROUP BY 
	C.CustomerID,
	C.CustomerName
ORDER BY
	COUNT(I.InvoiceID) DESC,
	MAX(IL.ExtendedPrice) DESC