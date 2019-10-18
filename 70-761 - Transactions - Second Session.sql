/* What happens when we have an open transaction? */

SELECT
	*
FROM
	Russ.Orders O
	LEFT JOIN Russ.OrderDetails OD ON O.OrderKey = OD.OrderKey

/*
In this case, the C part of ACID locked out our select
	statement - the database was inbetween states of consistency
	because the transaction was open
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @OrderKey int;
INSERT Russ.Orders (OrderDate, CustomerName) VALUES ('1/2/2018', 'Bob''s Legos');
SET @OrderKey = SCOPE_IDENTITY();
INSERT Russ.OrderDetails(OrderKey, ItemName, ItemCost, Quantity)
	VALUES (@OrderKey, 'Lego Starwars XWing', 399.99, 10)

/*
Why could I do this though?  SQL Server determined that the open transaction
	would not be effected by the addition of another record
*/



/* Isolation levels */
SELECT * FROM GameList

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
SELECT * FROM GameList
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

/* Read uncommitted lets you look at data that is in
	an inconsistent state.  What happens if the transaction
	gets rolled back?
*/

SELECT * FROM GameList


/* Another interesting option... this one requires something
	to be setup on the database though...
*/
use master
ALTER DATABASE TransactionsNStuff SET READ_COMMITTED_SNAPSHOT ON
use TransactionsNStuff


SELECT * FROM GameList

/*
Hmm.... we can read the data, but there is an open
	transaction...  We're getting data from the snapshot
	that is being created...
*/

SELECT * FROM GameList