/* ---------------------------------
	TRANSACTIONS:
*/ ---------------------------------

/*
A transaction is a unit of work that involves changes to
	data or structure (in SQL Server at least).  

A - atomic (all the work in the transaction completes, or 
		non of the work in the transaction completes)
C - consistent (transaction transitions the database from
		one consistent state to another while adhering
		to the data model, triggers, etc.)
I - isolated (the intermediate changes are only visible to
		the transaction that made the change)
D - durable (when transaction is commited, data will survive
		a crash to SQL Server engine or server)

*/

/*
CREATE TABLE TransactionsNStuff
(
	TransactionKey int IDENTITY(1,1) PRIMARY KEY,
	IntValue int NOT NULL,
	StringValue varchar(255) NULL,
	AnotherStringValue varchar(255) NULL,
	CreateDate datetime DEFAULT(GETDATE()) NOT NULL
)

CREATE SCHEMA Russ

CREATE TABLE Russ.Orders
(
	OrderKey int IDENTITY(1,1) PRIMARY KEY,
	OrderDate datetime NOT NULL,
	CustomerName varchar(255) NOT NULL
)
--DROP TABLE Russ.Orders
CREATE TABLE Russ.OrderDetails
(
	OrderDetailKey int IDENTITY(1,1) PRIMARY KEY,
	OrderKey int NOT NULL REFERENCES Russ.Orders(OrderKey),
	ItemName varchar(255) NOT NULL,
	ItemCost money NOT NULL,
	Quantity int NOT NULL,
)
--DROP TABLE Russ.OrderDetails
*/

/* Any dangers here?  */
DECLARE @OrderKey int;
INSERT Russ.Orders (OrderDate, CustomerName) 
	VALUES ('1/1/2018', 'Best Buy');
SET @OrderKey = SCOPE_IDENTITY();
INSERT Russ.OrderDetails(OrderKey, ItemName, ItemCost, Quantity)
	VALUES (@OrderKey, 'Lego Star Wars Set 70611', 79.99, 10);


/* Let's try again and see what happens when it breaks */
DECLARE @OrderKey int;
INSERT Russ.Orders (OrderDate, CustomerName) 
	VALUES ('1/2/2018', 'Best Buy');
SET @OrderKey = SCOPE_IDENTITY();
INSERT Russ.OrderDetails(OrderKey, ItemName, ItemCost)
	VALUES (@OrderKey, 'Lego Mindcraft Set 70829', 49.99)

-------

SELECT
	*
FROM
	Russ.Orders O
	LEFT JOIN Russ.OrderDetails OD ON O.OrderKey = OD.OrderKey


SET XACT_ABORT ON;
/*
Any run-time error will roll back the transaction.  
	Gives more predictable/expected behavior when
	running into errors

Default is off - some errors rollback, some
	do not
*/

/* Will this fix our problem? */
DECLARE @OrderKey int;
INSERT Russ.Orders (OrderDate, CustomerName) VALUES ('1/2/2018', 'Best Buy');
SET @OrderKey = SCOPE_IDENTITY();
INSERT Russ.OrderDetails(OrderKey, ItemName, ItemCost)
	VALUES (@OrderKey, 'Lego Indiana Jones Set 90123', 69.99)


SELECT
	*
FROM
	Russ.Orders O
	LEFT JOIN Russ.OrderDetails OD ON O.OrderKey = OD.OrderKey

/* No - the above is not a transaction - it is several transactions.
	SQL Server uses an autocommit approach when a transaction is
	not defined.  Means - each statement is a transaction.

The define some statements to be transactional, others are not.
	-INSERT, UPDATE, DELETE, SELECT - transactional
	-Setting a variable, not transactional

Only transactional statements will be rolled back (Page 268 - Exam Tip)
 */


/* Let's look at a simple transaction */

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET XACT_ABORT OFF
BEGIN TRANSACTION	

	DECLARE @OrderKey int;
	INSERT Russ.Orders (OrderDate, CustomerName) VALUES ('1/2/2018', 'Best Buy');
	SET @OrderKey = SCOPE_IDENTITY();
	INSERT Russ.OrderDetails(OrderKey, ItemName, ItemCost)
		VALUES (@OrderKey, 'Lego Halo Set 10555', 89.99)
SELECT * FROM Russ.Orders
COMMIT TRANSACTION
ROLLBACK TRANSACTION
SELECT
	*
FROM
	Russ.Orders O
	LEFT JOIN Russ.OrderDetails OD ON O.OrderKey = OD.OrderKey

/* This time, the entire transaction was rolled back when the
	error occurred.  No bad data - ACID compliant
*/

/*
You can set SQL Server to run in a different mode - Implicit 
	transactions.  In this mode, SQL creates a transaction
	anytime you run a transactional statement.  You have to
	manually commit the transaction when in this mode.

I wouldn't use...
*/

SET IMPLICIT_TRANSACTIONS ON
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @OrderKey int;
INSERT Russ.Orders (OrderDate, CustomerName) VALUES ('3/1/2018', 'Walmart');
SET @OrderKey = SCOPE_IDENTITY();
INSERT Russ.OrderDetails(OrderKey, ItemName, ItemCost, Quantity)
	VALUES (@OrderKey, 'Lego Halo Set 10555', 89.99, 100)

PRINT @@TRANCOUNT

/*
ROLLBACK TRANSACTION
COMMIT TRANSACTION
*/

SET IMPLICIT_TRANSACTIONS OFF


/*
Remember - rolling back a transaction only effects
	transactional statements
*/

BEGIN TRANSACTION

	DECLARE @SimpleTable TABLE (valueOne int, valueTwo int)
	INSERT @SimpleTable (valueOne, valueTwo) VALUES
		(1,2),
		(2,3),
		(3,5)
	SELECT * FROM @SimpleTable

ROLLBACK TRANSACTION

SELECT * FROM @SimpleTable


/*
SQL Server lets you create a transaction within a transaction,
	but it doesn't really support the idea.  Example on page 273
	shows that as soon as any ROLLBACK statement is issued,
	SQL Server rolls back everything in the transaction - even
	the statements that were in nested transactions that were
	committed.
*/

/*
You can name a transaction - seems like the mechanism is in
	place to ensure you are rolling back the outermost 
	transaction.  The name has to match exactly (case sensitive
	or as they put it - a binary match.  Very little use it seems...

	A working example
*/

BEGIN TRANSACTION OuterTrans
	BEGIN TRANSACTION InnerTrans
	PRINT 'Transaction Count ' + CAST(@@TRANCOUNT AS varchar)
	COMMIT TRANSACTION
	PRINT 'Transaction Count ' + CAST(@@TRANCOUNT AS varchar)
ROLLBACK TRANSACTION OuterTrans
PRINT 'Transaction Count ' + CAST(@@TRANCOUNT AS varchar)


/*
This doesn't work because the named transaction
	we are trying to rollback is not the outermost 
	transaction
*/
SET XACT_ABORT OFF;  --To show the way it works, turning this off
BEGIN TRANSACTION OuterTrans
	BEGIN TRANSACTION InnerTrans1
	BEGIN TRANSACTION InnerTrans2
	PRINT 'Transaction Count ' + CAST(@@TRANCOUNT AS varchar)
	ROLLBACK TRANSACTION InnerTrans2
	PRINT 'Transaction Count ' + CAST(@@TRANCOUNT AS varchar)
ROLLBACK TRANSACTION OuterTrans

/* 
Save points allow you to preserve portions of a transaction
	if you need.  They do involve nesting transactions.
	Save points can be rolled back to, but you have to start with the 
	inner most transaction first
*/

CREATE TABLE Russ.OurTest
(
	ValueOne varchar(10) NOT NULL
)

BEGIN TRANSACTION
	SAVE TRANSACTION Test1
	INSERT INTO Russ.OurTest VALUES ('Test 1')

	SAVE TRANSACTION Test2
	INSERT INTO Russ.OurTest VALUES ('Test 2')

	SAVE TRANSACTION Test3
	INSERT INTO Russ.OurTest VALUES ('Test 3')

	ROLLBACK TRANSACTION Test3
	ROLLBACK TRANSACTION Test2

	SAVE TRANSACTION Test4
	INSERT INTO Russ.OurTest VALUES ('Test 4')

COMMIT TRANSACTION

SELECT * FROM Russ.OurTest

DROP TABLE Russ.OurTest
CREATE TABLE Russ.OurTest
(
	ValueOne varchar(10) NOT NULL
)

BEGIN TRANSACTION
	SAVE TRANSACTION Test1
	INSERT INTO Russ.OurTest VALUES ('Test 1')

	SAVE TRANSACTION Test2
	INSERT INTO Russ.OurTest VALUES ('Test 2')

	SAVE TRANSACTION Test3
	INSERT INTO Russ.OurTest VALUES ('Test 3')

	ROLLBACK TRANSACTION Test1
	ROLLBACK TRANSACTION Test3

	SAVE TRANSACTION Test4
	INSERT INTO Russ.OurTest VALUES ('Test 4')

COMMIT TRANSACTION

SELECT * FROM Russ.OurTest

/*
	WITH MARK: Gives you the
	option on a database restore to restore to a specific
	marked transaction (i.e. a good way to clear out
	test data if you put it in).
*/

/*
	Isolation levels:
	https://www.brentozar.com/isolation-levels-sql-server/
	https://www.red-gate.com/simple-talk/sql/t-sql-programming/questions-about-t-sql-transaction-isolation-levels-you-were-too-shy-to-ask/

	Let's look at a few of these to give you a flavor..
*/


CREATE TABLE GameList
(
	GameKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	GameName varchar(255) NOT NULL,
	ReleaseDate datetime NOT NULL
)

INSERT GameList (GameName, ReleaseDate) VALUES ('God of War PS4', '04/11/2018')

BEGIN TRANSACTION
	
	INSERT GameList (GameName, ReleaseDate) VALUES ('Red Dead Redemption 2', '10/15/2018')
	INSERT GameList (GameName, ReleaseDate) VALUES ('Ni Nu Kuni 2', '3/14/2018')

ROLLBACK TRANSACTION
COMMIT TRANSACTION

--USE master;
--use TransactionsNStuff;

sp_who2