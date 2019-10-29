/* How do you design a database */









/*
	Domain expertise is important
	-Gender?
	-Grocery Store?
	-Cars?
*/	








/*
	Balance with MVP

*/









/*
	What is normalization and why do we care about it?

*/







/*


Database normalization is the process of structuring a relational 
database[clarification needed] in accordance with a series of so-called 
normal forms in order to reduce data redundancy and improve data integrity. 
It was first proposed by Edgar F. Codd as part of his relational model.


*/





/* Anomolies */








SELECT * FROM Application.People
{ 
	"OtherLanguages": [] ,
	"HireDate":"2012-03-05T00:00:00",
	"Title":"Team Member",
	"PrimarySalesTerritory":"New England",
	"CommissionRate":"3.62"
}

{ 
	"OtherLanguages": ["Polish","Chinese","Japanese"] ,
	"HireDate":"2008-04-19T00:00:00",
	"Title":"Team Member","PrimarySalesTerritory":"Plains","CommissionRate":"0.98"}

/* 

	Let's look at this topic without talking about the forms...

	Need some way to uniquely identify a record?
	Does the table have information about more than one subject/object/thing
	Do you have multiple columns that are storing the same value?
	Do you have more than one thing in a column?
	Does the column store the same thing consistently?
	Does one thing relate to many of another?
	Does one column relate to another in the same table?
	Are any of the values calculated based on other columns


*/



/*
Naming Conventions - review what we've already
	talked about
*/










/* 
	Scripts that run without user intervention

*/





/*

Semicolon vs. GO

GO tells SSMS and other tools to send the script to that point as a batch.
Semicolon is used to indicate the end of an individual SQL statement


CREATE DEFAULT, CREATE FUNCTION, CREATE PROCEDURE, CREATE RULE, CREATE TRIGGER, 
and CREATE VIEW statements cannot be combined with other statements in a batch. 
The CREATE statement must begin the batch. All other statements that follow 
in that batch will be interpreted as part of the definition of the 
first CREATE statement.


Check to see if something exists using the system tables and some 
simple TSQL

Run your script multiple times against the same database and against new 
	databases to make sure it works

*/





/*

Create tables

*/

CREATE TABLE Teams
(
	TeamKey int NOT NULL,
	TeamName varchar(255) NOT NULL
)










/* 

Alter tables


*/








/* Primary keys - what are they? */

/* Natural vs. artificial/surrogate keys */
 
/* How to create these inside of SQL Server */





CREATE TABLE SampleTable
(
	SampleTableKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SomeValue varchar(50)
);


CREATE TABLE SampleTableV2
(
	SampleTableKeyV2 int IDENTITY(1,1) NOT NULL,
	SomeValue varchar(50)
);

ALTER TABLE SampleTableV2
ADD CONSTRAINT pk_SampleTableV2 PRIMARY KEY (SampleTableKeyV2);


DROP TABLE SampleTable
DROP TABLE SampleTableV2




CREATE TABLE Parents
(
	ParentKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ParentName varchar(50) NOT NULL
);

CREATE TABLE Children
(
	ChildKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ChildName varchar(50) NOT NULL,
	ParentKey int NOT NULL REFERENCES Parents(ParentKey)
);

CREATE TABLE ChildrenV2
(
	ChildKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ChildName varchar(50) NOT NULL,
	ParentKey int NOT NULL
);

ALTER TABLE ChildrenV2
ADD CONSTRAINT fk_ParentKey FOREIGN KEY (ParentKey)
	REFERENCES Parents (ParentKey);









CREATE TABLE ChildrenV3
(
	ChildKey int IDENTITY(1,1) NOT NULL,
	ChildName varchar(50) NOT NULL,
	ParentKey int NOT NULL,
	CONSTRAINT pk_ChildrenV3 PRIMARY KEY (ChildKey),
	CONSTRAINT fk_ParentKeyV3 FOREIGN KEY (ParentKey) REFERENCES
		Parents(ParentKey)
);



DROP TABLE Parents;
DROP TABLE ChildrenV2;
DROP TABLE Children;
DROP TABLE ChildrenV3;






DROP TABLE Parents;


