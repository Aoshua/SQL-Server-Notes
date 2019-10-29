IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Homework')
BEGIN
    EXEC('CREATE SCHEMA Homework')
END

DROP TABLE Homework.Countries
CREATE TABLE Homework.Countries
(
    CountryKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Country varchar(50)
)

INSERT Homework.Countries (Country) VALUES
    ('USA'),
    ('France'),
    ('Spain')


DROP TABLE Homework.Employees
CREATE TABLE Homework.Employees
(
    EmployeeKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    LastName varchar(50) NOT NULL,
    MiddleName varchar(50) NULL,
    FirstName varchar(50) NOT NULL,
    HireDate date NOT NULL,
    Termination date NULL,
    CountryKey int NOT NULL
)


DROP TABLE Homework.FrenchEmployees;
CREATE TABLE Homework.FrenchEmployees
(    
    LastName varchar(50) NOT NULL,
    MiddleName varchar(50) NULL,
    FirstName varchar(50) NOT NULL,
    HireDate date NOT NULL,
    Country varchar(50) DEFAULT ('France')
)
INSERT Homework.FrenchEmployees (LastName, MiddleName, FirstName, HireDate)
VALUES
    ('Moreau', NULL, 'Alex', '01/01/2012'),
    ('Blanctorche', 'A', 'Elisabeth', '12/15/2015'),
    ('Sorel', NULL, 'Raphael', '06/21/1995'),
    ('Dorian', 'Laslo', 'Arno', '05/26/2019')




SELECT
	*
FROM
	Homework.Countries

SELECT
	*
FROM
	Homework.Employees

SELECT
	*
FROM
	Homework.FrenchEmployees




/* DML - Update, Insert, Delete, Merge */


/*
    A couple of quick points - 

    - No undo as part of these statements.  We'll cover how to add this with other
        database commands later
    - There are some techniques to help minimize mistakes.  It is a habit you should 
        form
    - Depending on the company, space, verticle, etc., these are functions you likely
        will not get to run on a production environment yourself.  We'll talk about
        how to create a script that runs unattended.



*/






/*
    Inserts

    INSERT <table name> (<list of columns) VALUES (<list of values>)
*/




INSERT Homework.Employees (Lastname, FirstName, HireDate, CountryKey)
VALUES ('Reed', 'Russell', '04/14/1998', 1)



SELECT * FROM Homework.Employees




/* 
    Couple of callouts
     - if the column doesn't allow nulls and does not have a default value
        assigned, your insert statement has to provide a value for the 
        column
     - The order of your columns doesn't have to match the order of the columns
        in the table
     - The order of your values should match the order of the columns in the
        first part of your query

*/





/* Multiple Rows */
INSERT Homework.Employees (Lastname, FirstName, HireDate, CountryKey)
VALUES 
    ('Smith', 'John', '05/15/2015', 1),
    ('Graybeal', 'Diane', '06/01/2008', 1),
    ('Towns', 'Adam', '11/15/2005', 1)





/* The above query inserts all three rows in a single batch where
    the other example would insert rows one at a time, a single
    batch for each row.
*/











/* Updates */

UPDATE Homework.Employees
SET MiddleName = 'Johnson'
WHERE LastName = 'Towns'

SELECT * FROM Homework.Employees






/*
UPDATE <table> 
SET <Column> = <value>
WHERE
    <predicate>

*/







UPDATE Homework.Employees
SET HireDate = '01/01/2000'





/* 
    If you miss the predicate, an UPDATE will change
    every row in the table
*/





SELECT
    *
FROM
    Homework.Employees

WHERE  
    LastName = 'Reed'








--SELECT
--    *
--FROM

UPDATE
    Homework.Employees 
SET
    HireDate = '04/12/1998'

WHERE  
    LastName = 'Reed'









/* DELETE */



DELETE 
    Homework.Employees
WHERE 
    LastName = 'Smith'


SELECT * FROM Homework.Employees


/* 
    DELETE <table>
    WHERE <predicate>

*/



SELECT
    *
FROM   
    Homework.Employees

WHERE
    LastName = 'Towns'



--SELECT
--    *
--FROM   
DELETE
    Homework.Employees

WHERE
    LastName = 'Towns'

SELECT * FROM Homework.Employees




/*
    INSERT can use the results of another query
    as its values

*/




SELECT 
    *
FROM   
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Countries AS C ON FE.Country = C.country




/* 
    Why join your staging table to a lookup table?

*/



SELECT 
    FE.FirstName,
    FE.MiddleName,
    FE.Lastname,
    FE.HireDate,
    C.countryKey
FROM   
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Countries AS C ON FE.Country = C.country














INSERT Homework.Employees (FirstName, MiddleName, LastName, HireDate, CountryKey)
SELECT 
    FE.FirstName,
    FE.MiddleName,
    FE.Lastname,
    FE.HireDate,
    C.countryKey
FROM   
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Countries AS C ON FE.Country = C.country


SELECT * FROM Homework.Employees









/* 
    How can we make sure we don't insert the data multiple times?

*/











--INSERT Homework.Employees (FirstName, MiddleName, LastName, HireDate, CountryKey)
SELECT 
    FE.FirstName,
    FE.MiddleName,
    FE.Lastname,
    FE.HireDate,
    C.countryKey
FROM   
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Countries AS C ON FE.Country = C.country
    LEFT JOIN Homework.Employees E ON FE.FirstName = E.FirstName 
        AND FE.MiddleName = E.MiddleName
        AND FE.LastName = E.LastName

WHERE
    E.EmployeeKey IS NULL










--INSERT Homework.Employees (FirstName, MiddleName, LastName, HireDate, CountryKey)
SELECT 
    FE.FirstName,
    FE.MiddleName,
    FE.Lastname,
    FE.HireDate,
    C.countryKey
FROM   
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Countries AS C ON FE.Country = C.country
    LEFT JOIN Homework.Employees E ON FE.FirstName = E.FirstName 
        AND ISNULL(FE.MiddleName,'') = ISNULL(E.MiddleName, '')
        AND FE.LastName = E.LastName

WHERE
    E.EmployeeKey IS NULL









/* 
DELETE has some similiar things we can use
*/


SELECT * FROM Homework.Employees
DELETE Homework.Employees
WHERE
    EmployeeKey IN
    (
        SELECT
            Employeekey
        FROM
            Homework.Employees
        WHERE  
            DATEDIFF(YEAR, HireDate, GETDATE()) <= 4
    )











/* You can also use a query to get rid of rows as long
    as the table you want to delete from is also in the 
    query
*/


DELETE Homework.Employees
--SELECT *
FROM
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Employees AS E ON FE.FirstName = E.FirstName 
        AND ISNULL(FE.MiddleName,'') = ISNULL(E.MiddleName, '')
        AND FE.LastName = E.LastName

WHERE
    E.EmployeeKey IS NOT NULL    




/*
Sometimes you're given data in a database friendly format and you need to import it in

We have a couple of ways to do this

*/


TRUNCATE TABLE Homework.SpanishEmployees
SELECT * FROM Homework.SpanishEmployees

INSERT Homework.Employees (FirstName, MiddleName, LastName, HireDate, CountryKey) VALUES ('Don','','Flamenco','09/01/2019',3)
INSERT Homework.Employees (FirstName, MiddleName, LastName, HireDate, CountryKey) VALUES ('Luis','','Sera','09/01/2019',3)
INSERT Homework.Employees (FirstName, MiddleName, LastName, HireDate, CountryKey) VALUES ('Eric','J','Lecarde','09/01/2019',3)

SELECT * FROM Homework.Employees


/*

You can get information about the changes that are being made leveraging the OUTPUT
    clause

*/


INSERT Homework.Employees (FirstName, MiddleName, LastName, HireDate, CountryKey)
OUTPUT inserted.*
SELECT 
    FE.FirstName,
    FE.MiddleName,
    FE.Lastname,
    FE.HireDate,
    C.countryKey
FROM   
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Countries AS C ON FE.Country = C.country
    LEFT JOIN Homework.Employees E ON FE.FirstName = E.FirstName 
        AND ISNULL(FE.MiddleName,'') = ISNULL(E.MiddleName, '')
        AND FE.LastName = E.LastName

WHERE
    E.EmployeeKey IS NULL

SELECT * FROM Homework.Employees












DELETE Homework.Employees
OUTPUT deleted.EmployeeKey, deleted.LastName
FROM
    Homework.FrenchEmployees AS FE
    INNER JOIN Homework.Employees AS E ON FE.FirstName = E.FirstName 
        AND ISNULL(FE.MiddleName,'') = ISNULL(E.MiddleName, '')
        AND FE.LastName = E.LastName

WHERE
    E.EmployeeKey IS NOT NULL    


SELECT * FROM Homework.Employees





/* the inserted and deleted tables are special tables that are generated
    dynamically based on the type of query being executed.  They match
    the columns and types of the table that is being affected by the 
    DML statement

*/




SELECT * FROM Homework.Employees

UPDATE Homework.Employees
SET Hiredate = '09/16/2019'
OUTPUT 
    inserted.EmployeeKey,
    inserted.Hiredate [NewHireDate],
    deleted.Hiredate [OldHireDate],
	inserted.*,
	deleted.*
WHERE HireDate = '09/1/2019'




/* An UPDATE statement generates both an inserted and a deleted special
    table.  Inserted contains the new value, deleted the old value
*/






DECLARE @AuditTable TABLE
(
    EmployeeKey int NOT NULL,
    NewHireDate date NOT NULL,
    OldHireDate date NOT NULL
)



UPDATE Homework.Employees
SET Hiredate = '09/16/2019'
OUTPUT 
    inserted.EmployeeKey,
    Inserted.Hiredate [NewHireDate],
    deleted.Hiredate [OldHireDate]
INTO @AuditTable
WHERE HireDate = '09/01/2019'

SELECT
    *
FROM 
    @AuditTable A
	INNER JOIN Homework.Employees E ON A.EmployeeKey = E.EmployeeKey







/*
    Finally - you can stuff the results of OUTPUT into a table
        variable that you can use for other purposes further down
        in your query
*/







/*

https://docs.microsoft.com/en-us/sql/t-sql/statements/merge-transact-sql?view=sql-server-2017

SQL Server offers a statement that does all three CRUD statements at once (CREATE UPDATE DELETE)


*/


DROP TABLE Homework.FrenchEmployeesV2;
CREATE TABLE Homework.FrenchEmployeesV2
(    
    LastName varchar(50) NOT NULL,
    MiddleName varchar(50) NULL,
    FirstName varchar(50) NOT NULL,
    HireDate date NOT NULL,
    Country varchar(50) DEFAULT ('France')
)
INSERT Homework.FrenchEmployeesV2 (LastName, MiddleName, FirstName, HireDate)
VALUES
    ('Blanctorche', NULL, 'Elisabeth', '12/15/2015'),
    ('Sorel', NULL, 'Raphael', '10/31/2019'),
    ('Dorian', 'Laslo', 'Arno', '10/31/2019'),
    ('Pogba', NULL, 'Paul', '01/01/2021')




MERGE
    Homework.Employees AS TARGET
USING 
    (
        SELECT
            FE.FirstName,
            FE.MiddleName,
            FE.LastName,
            FE.HireDate,
            C.CountryKey
        FROM
            Homework.FrenchEmployeesV2 FE
            INNER JOIN Homework.Countries C ON FE.country = C.country
    ) AS SOURCE
    ON (
        Target.FirstName = Source.FirstName
        AND
        Target.LastName = Source.Lastname
        )
    WHEN MATCHED THEN
        UPDATE SET Target.MiddleName = Source.MiddleName
    WHEN NOT MATCHED THEN
        INSERT (FirstName, MiddleName, Lastname, Hiredate, CountryKey)
        VALUES (Source.FirstName, Source.MiddleName, Source.LastName, Source.HireDate, Source.Countrykey)
    ;



SELECT * FRom homework.Employees