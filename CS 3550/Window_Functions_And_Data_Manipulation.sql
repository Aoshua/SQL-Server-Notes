/* Query #1 (15 points):

Write the necessary INSERT statements to add the Best Buy locations in Nebraska 
	and Alaska.  These can be found at https://stores.bestbuy.com/.

The store in Papillion, NE is closing.  Write a delete statement to remove this 
	location from the database (completely ignoring our conversation about why 
	this is so bad to do).

The store in Lincoln, NE has moved locations.  Write an update statement that
	changes its address to:
	42 Balcome
	West Sussex, NE 68511

A new store has opened up in Worcester, MA.  Write an insert statement to add 
	the store (use the address from the site).

Script to create the table included below.

*/

CREATE SCHEMA [Homework];

CREATE TABLE [Homework].Locations
(
	LocationKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	LocationName varchar(50) NOT NULL,
	Address1 varchar(50) NOT NULL,
	Address2 varchar(50) NULL,
	City varchar(50) NOT NULL,
	StateCode char(2) NOT NULL,
	ZipCode char(5) NOT NULL,
	Zip4 char(4) NULL
);

INSERT INTO [Homework].Locations (LocationName, Address1, Address2, City, StateCode, ZipCode, Zip4)
	VALUES ('Best Buy North Anchorage', '1200 N Muldoon Rd Ste G', NULL, 'Ancorage', 'AK', 99504, NULL),
			('Best Buy Anchorage', '800 E Dimond Blvd', NULL, 'Ancorage', 'AK', 99515, NULL),
			('Magnolia Home Theater Anchorage', '800 E Dimond Blvd', NULL, 'Anchorage', 'AK', 99515, NULL),
			('Best Buy Grand Island', '3404 W 13th St', NULL, 'Grand Island', 'NE', 68803, NULL),
			('Best Buy Lincoln', '6910 O Street', NULL, 'Lincoln', 'NE', 68510, NULL),
			('Best Buy Omaha East', '115 N 76th St', NULL, 'Omaha', 'NE', 68114, NULL),
			('Best Buy West Omaha', '333 N 170th St', NULL, 'Omaha', 'NE', 68118, NULL),
			('Best Buy Papillion', '7949 Towne Center Pkwy', NULL, 'Papillion', 'NE', 68046, NULL)

SELECT * FROM Homework.Locations

DELETE FROM Homework.Locations WHERE City = 'Papillion'

UPDATE 
	Homework.Locations
SET 
	Address1 = '42 Balcome',
	City = 'West Sussex',
	ZipCode = 68511
WHERE
	City = 'Lincoln'

INSERT INTO [Homework].Locations (LocationName, Address1, Address2, City, StateCode, ZipCode, Zip4)
	VALUES ('Best Buy Worcester', '7 Neponset St', NULL, 'Worcester', 'MA', 01606, NULL)

/* Question #2 (15 points):

You’ve been asked to send thank you gifts to customers who have purchased large quantities of your recently 
released chocolate animal series (stock item id’s 222, 223, 224, 225).  Your query 
needs to list the customer ID, the customer Name, have a column that totals units of each animal type, 
and a grand total for all animals.  To qualify for the gift, the customer must have purchased at least 300 
of any given animal type, or a total of 500 across all animal types.  Your final query should sort by
the total – largest to smallest.  You should get 20 rows – the first two look like this – 

CustomerID	CustomerName					Beetles	Echidnas	Frogs	Sharks	Total
441			Wingtip Toys (Keosauqua, IA)	216		432			0		96		744
573			Wingtip Toys (Marin City, CA)	264		0			312		168		744
*/
--sum quanities per customer in a derived table
-- sum case? alternative

SELECT 
	SC.CustomerID,
	SC.CustomerName,
	ISNULL(SUM(CASE WHEN SIL.StockItemID = 222 THEN SIL.Quantity END), 0) AS 'Beetles',
	ISNULL(SUM(CASE WHEN SIL.StockItemID = 223 THEN SIL.Quantity END), 0) AS 'Echidnas',
	ISNULL(SUM(CASE WHEN SIL.StockItemID = 224 THEN SIL.Quantity END), 0) AS 'Frogs',
	ISNULL(SUM(CASE WHEN SIL.StockItemID = 225 THEN SIL.Quantity END), 0) AS 'Sharks',
	SUM(CASE WHEN SIL.StockItemID IN (222, 223, 224, 225) THEN SIL.Quantity END) AS 'Total'
FROM
	Warehouse.StockItems AS WSI
	LEFT JOIN Sales.InvoiceLines AS SIL ON WSI.StockItemID = SIL.StockItemID
	LEFT JOIN Sales.Invoices AS SI ON SIL.InvoiceID = SI.InvoiceID
	LEFT JOIN Sales.Customers AS SC ON SI.CustomerID = SC.CustomerID
GROUP BY
	SC.CustomerID,
	SC.CustomerName
HAVING
	(SUM(CASE WHEN SIL.StockItemID = 222 THEN SIL.Quantity END) > 300 
	OR
	SUM(CASE WHEN SIL.StockItemID = 223 THEN SIL.Quantity END) > 300 
	OR
	SUM(CASE WHEN SIL.StockItemID = 224 THEN SIL.Quantity END) > 300 
	OR
	SUM(CASE WHEN SIL.StockItemID = 225 THEN SIL.Quantity END) > 300 )
	OR
	SUM(CASE WHEN SIL.StockItemID IN (222, 223, 224, 225) THEN SIL.Quantity END) > 500
ORDER BY
	Total DESC

/* Query #3 - 20 points

    Write a query that does the following:
    
    - filter down to customer's 525 and 831
    - For each customer, identify what invoices contain the top 2 or bottom 2
        line item costs (i.e. the top 2 and bottom 2 extended prices)
    - Ties on the extended price should be broken by invoice ID (smallest to largest)
    - With the invoices identified above, total all related invoice lines for
        each invoice and return the InvoiceID, the Customer's name and ID, and the
        total value (sum up extended price).  Order it by Customer Name and Invoice value
    - you'll need the Sales.Invoices table, the Sales.InvoiceLines table (joined on
        InvoiceID, and the Sales.CustomerID table, joined on CustomerID)

    You cannot hardcode the InvoiceID's - they need to be returned from the query.
    
    To solve this, you will need to use a window function.

    You should get 8 rows back.  Two rows in the results will look like the following:

    InvoiceID	CustomerID	CustomerName	                InvoiceTotal
    11976	    525	        Wingtip Toys (Claycomo, MO) 	284.63
    61704	    831	        Bhaavan Rai	                    20386.31

	See photo, or rank

*/
select * from sales.invoices

SELECT
	SI.InvoiceID,
	SC.CustomerID,
	SC.CustomerName,
	SUM(SIL.ExtendedPrice) AS [InvoiceTotal]
FROM
	Sales.Invoices AS SI
	LEFT JOIN Sales.InvoiceLines AS SIL ON SI.InvoiceID = SIL.InvoiceID
	LEFT JOIN Sales.Customers AS SC ON SI.CustomerID = SC.CustomerID
	LEFT JOIN
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY I.CustomerID ORDER BY IL.ExtendedPrice DESC, IL.InvoiceID) AS Largest,
			ROW_NUMBER() OVER(PARTITION BY I.CustomerID ORDER BY IL.ExtendedPrice ASC, IL.InvoiceID) AS Smallest,
			IL.InvoiceID
		FROM
			Sales.InvoiceLines AS IL
			LEFT JOIN Sales.Invoices as I on I.InvoiceID = IL.InvoiceID 
	) AS T ON T.InvoiceID = SI.InvoiceID
WHERE
	SC.CustomerID IN (525, 831)
	AND
	(T.Largest IN (1, 2)
	OR 
	T.Smallest IN (1, 2))
GROUP BY
	SI.InvoiceID,
	SC.CustomerID,
	SC.CustomerName
ORDER BY
	CustomerName,
	InvoiceTotal DESC