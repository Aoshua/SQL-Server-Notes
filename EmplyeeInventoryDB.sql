-- The design on this DB is garbage, so I apologize to whomever may be reading this. 
/* -----------------
	DROP TABLES:
*/ -----------------
-- Starting with dropping constraints
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Jobs') > 0
	BEGIN
		ALTER TABLE Jobs DROP CONSTRAINT FK_DepartmentJob
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'JobHistories') > 0
	BEGIN
		ALTER TABLE JobHistories DROP CONSTRAINT FK_EmployeeJobHistory
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Equipment') > 0
	BEGIN
		ALTER TABLE Equipment DROP CONSTRAINT FK_EmployeeEquipment
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Employees') > 0
	BEGIN
		ALTER TABLE Employees DROP CONSTRAINT FK_JobEmployee
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Departments') > 0
	BEGIN		
		ALTER TABLE Departments DROP CONSTRAINT FK_SupervisorDeparment
	END

-- Now dropping tables
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'EquipmentTypes') > 0
	BEGIN
		DROP TABLE IF EXISTS EquipmentTypes
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Jobs') > 0
	BEGIN
		DROP TABLE IF EXISTS Jobs
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Employees') > 0
	BEGIN
		DROP TABLE IF EXISTS Employees
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'JobHistories') > 0
	BEGIN
		DROP TABLE IF EXISTS JobHistories
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Equipment') > 0
	BEGIN
		DROP TABLE IF EXISTS Equipment
	END
IF (SELECT COUNT(*) FROM sys.tables WHERE name = 'Departments') > 0
	BEGIN		
		DROP TABLE IF EXISTS Departments
	END


/* -----------------
	CREATE TABLES:
*/ -----------------

CREATE TABLE EquipmentTypes
	(
		TypeID			int				NOT NULL	PRIMARY KEY IDENTITY(1,1),	
		TypeName		varchar(100)	NOT NULL
	)

CREATE TABLE Departments
	(
		DepartmentID	int				NOT NULL	PRIMARY KEY IDENTITY(1,1),	
		DepartmentName	varchar(200)	NOT NULL,	
		SupervisorID	int				NOT NULL
	)

CREATE TABLE Jobs
	(
		JobID			int				NOT NULL	PRIMARY KEY IDENTITY(1,1),	
		JobTitle		varchar(200)	NOT NULL,	
		Salary			smallmoney		NOT NULL,	
		DepartmentID	int				
	)
-- Salaray as smallmoney will suffice unless someone makes more than $214,748.3647 (unlikely)
-- DepartmentID can be NULL in the case that a supervisor manages more than one deparment

CREATE TABLE Employees
	(
		EmployeeID		int				NOT NULL	PRIMARY KEY IDENTITY(1,1),	
		FirstName		varchar(100)	NOT NULL,	
		LastName		varchar(100)	NOT NULL, 
		PreferredName	varchar(100)	NOT NULL,	
		Email			varchar(250)	NOT NULL, 
		HireDate		datetime		NOT NULL,
		PhoneNumber		varchar(16)		NOT NULL,	
		TerminationDate datetime				,	
		StreetAddress	varchar(250)	NOT NULL, 
		StateCode		char(2)			NOT NULL,	
		ZipCode			char(6)			NOT NULL,	
		JobID			int				NOT NULL
	)
	-- Length of 100 for first and last name because names in the USA (especially broken into first and last) will be shorter.
	-- Preferred name can be an empty string
	-- Phone number can be less than 16 if they don't format it so: 1 (801) 555-5555
	-- If termination date is NULL, the employee is still working
	-- State code is char(2) because all states have a unique 2 letter abrv.
	-- Zip code is char(6) because all zip codes are 6 numbers

CREATE TABLE JobHistories
	(
		JobHistoryID	int				NOT NULL	PRIMARY KEY IDENTITY(1,1),	
		EmployeeID		int				NOT NULL,	
		JobID			int				NOT NULL,	
		StartDate		datetime		NOT NULL,	
		EndDate			datetime					
	)
	-- If end date is NULL, the job is current

CREATE TABLE Equipment
	(
		EquipmentID		int				NOT NULL	PRIMARY KEY IDENTITY(1,1),	
		EquipmentName	varchar(100)	NOT NULL,	
		SerialNumber	varchar(100)	NOT NULL,	
		DatePurchased	datetime		NOT NULL,	
		DateRetired		datetime				,	
		EmployeeID		int						,
		TypeID			int				NOT NULL
	)
	-- I can't image a serial number being larger than 100 char
	-- If date retired is NULL, the equipment is still in use
	-- EmployeeID can be NULL (Equipment may not be assigned to anyone yet)


/* -----------------
	INSERT DATA:
*/ -----------------

INSERT INTO EquipmentTypes
	( TypeName )
	VALUES
	( 'Laptop' ), 
	( 'Desktop')

INSERT INTO Equipment
	( EquipmentName, SerialNumber, DatePurchased, DateRetired, EmployeeID, TypeID )
	VALUES
	( 'Dell Inspiron Small Desktop', 'C02FX0C5DHJF', '10-17-2018', NULL, NULL,  2), 
	( 'HP 17.3" AMD Ryzen 3', 'L02PB7C5ZHRX', '08-21-2018', NULL, NULL,  1),
	( 'ASUS X441BA 14" HD Notebook', 'L02PB7C5ZHRX', '11-03-2018', NULL, NULL,  1)

INSERT INTO Departments
	( DepartmentName, SupervisorID )
	VALUES
	( 'Information Technology',  1), 
	( 'Accounting',  1)

INSERT INTO Jobs
	( JobTitle, Salary, DepartmentID )
	VALUES
	( 'IT Specialist',  34400, 1), 
	( 'IT Manager',  92300, 1),
	( 'Accountant',  39600, 2),
	( 'Accounting Manager',  77800, 2),
	( 'Bidepartmental Manager', 104000, NULL), -- Mangages two departments. Department ID isn't super important here because supervisors are connected by supervisorID to dept
	( 'Master IT Specialist', 55000, 1)

INSERT INTO Employees
	( FirstName, LastName, PreferredName, Email, HireDate, PhoneNumber, TerminationDate, StreetAddress, StateCode, ZipCode, JobID)
	VALUES
	( 'Joshua',  'Abbott', 'Josh', 'josh64@gmail.com', '06-26-2019', '1 (801) 123-4567', NULL, '2345 E. 8574 S.', 'UT', 84067, 5),
	( 'Joffrey', 'Griffin', 'Jeff', 'joffreygriffin@gmail.com', '04-05-2019', '1 (801) 753-9512', NULL, '9874 W. 8907 S.', 'UT', 84256, 1),
	( 'Sofia', 'Griffin', 'Sofia', 'sofiagriffin@gmail.com', '04-01-2019', '1 (801) 753-1596', NULL, '9874 W. 8907 S.', 'UT', 84256, 3),
	( 'Rosanna', 'Peterson', 'Rosy', 'rosannarosanna@gmail.com', '11-08-2019', '452-7896', NULL, '7854 N. Park Blv.', 'UT', 84101, 1),
	( 'Niel', 'Armstrong', '', 'onesmallstep@comcast.net', '10-30-2017', '842-8624', NULL, '32 Main Street Apt. 303', 'UT', 84102, 3)

INSERT INTO JobHistories
	( EmployeeID, JobID, StartDate, EndDate)
	VALUES
	( 1, 5, '06-26-2019', NULL ),
	( 2, 1, '04-05-2019', NULL ),
	( 3, 3, '04-01-2019', NULL ),
	( 4, 1, '11-08-2019', NULL ),
	( 5, 3, '10-30-2017', NULL )

-- Assign equipment:
UPDATE Equipment
	SET	EmployeeID = 1
	WHERE EquipmentID IN (1, 2) --Two for manager
UPDATE Equipment
	SET	EmployeeID = 4
	WHERE EquipmentID = 3		-- One for other

-- Promotion:
UPDATE Employees
	SET	JobID = 6
	WHERE EmployeeID = 5
UPDATE JobHistories
	SET EndDate = '10-12-2019'
	WHERE JobHistoryID = 5
INSERT INTO JobHistories
	( EmployeeID, JobID, StartDate, EndDate)
	VALUES
	( 5, 6, '10-12-2019', NULL )
-- The above will result in a new job title, salary, and updated job history for Niel

select * from Departments
/* -----------------
	SET FOREIGN KEY CONSTRAINTS:
*/ -----------------
--These have been a pain in my ass haha...
ALTER TABLE Departments
	ADD CONSTRAINT FK_SupervisorDeparment
	FOREIGN KEY (SupervisorID) REFERENCES Employees(EmployeeID)

ALTER TABLE Jobs
	ADD CONSTRAINT FK_DepartmentJob
	FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)

ALTER TABLE Employees
	ADD CONSTRAINT FK_JobEmployee
	FOREIGN KEY (JobID) REFERENCES Jobs(JobID)

ALTER TABLE JobHistories
	ADD CONSTRAINT FK_EmployeeJobHistory
	FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)

ALTER TABLE Equipment
	ADD CONSTRAINT FK_EmployeeEquipment
	FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)


/* -----------------
	SELECT EMPLOYEE INFO
*/ -----------------
SELECT
	E.EmployeeID,
	E.FirstName + ' ' + E.LastName AS [FullName],
	J.JobTitle,
	D.DepartmentName,
	(
		SELECT
			EMP.FirstName + ' ' + EMP.LastName
		FROM
			Employees AS EMP
			JOIN Departments AS DEPT ON EMP.EmployeeID = DEPT.SupervisorID
		WHERE
			DEPT.DepartmentID = D.DepartmentID
		
	) AS [Supervisor]
FROM
	Employees AS E
	LEFT JOIN Jobs AS J ON E.JobID = J.JobID
	LEFT JOIN Departments AS D ON J.DepartmentID = D.DepartmentID


/* -----------------
	OTHER DB QUERIES
*/ -----------------
-- QUERY ONE: --
DECLARE @MyDate datetime = '10/07/2015'
SELECT
	DATEADD(DAY, 28, GETDATE()) AS [28 Days from Now],
	DATEADD(DAY, 1, DATEADD(YEAR, 1, GETDATE())) AS [1 Year and 1 Day from Now],
	DATEDIFF(DAY, @MyDate, '12/25/2017') AS [Days Between @MyDate and Christmas 2017],
	FORMAT(@MyDate, 'dddd' ) AS [Name of the Day @MyDate]

-- QUERY TWO: --
SELECT
	SUM(IL.ExtendedPrice) AS [Total sales of Donut Flashdrive in 2015]
FROM
	Sales.InvoiceLines AS IL
	LEFT JOIN Sales.Invoices AS I ON IL.InvoiceID = I.InvoiceID
WHERE
	YEAR(I.InvoiceDate) = '2015'
	AND
	IL.[Description] LIKE '%donut%'

-- QUERY THREE: --
SELECT
	SP.StateProvinceName AS [State],
	COUNT(CU.CustomerID) AS [Total Customers]
FROM
	Sales.Customers AS CU
	FULL OUTER JOIN Application.Cities AS CI ON CU.DeliveryCityID = CI.CityID
	LEFT JOIN Application.StateProvinces AS SP ON CI.StateProvinceID = SP.StateProvinceID
GROUP BY
	SP.StateProvinceName
ORDER BY
	[Total Customers] ASC

-- QUERY FOUR: --
SELECT
	SI.StockItemID,
	SI.StockItemName,
	ISNULL(SUM(CASE WHEN YEAR(I.InvoiceDate) = '2013' THEN IL.ExtendedPrice END), 0) AS [2013 Sales],
	ISNULL(SUM(CASE WHEN YEAR(I.InvoiceDate) = '2014' THEN IL.ExtendedPrice END), 0) AS [2014 Sales],
	ISNULL(SUM(CASE WHEN YEAR(I.InvoiceDate) = '2015' THEN IL.ExtendedPrice END), 0) AS [2015 Sales],
	ISNULL(SUM(CASE WHEN YEAR(I.InvoiceDate) = '2016' THEN IL.ExtendedPrice END), 0) AS [2016 Sales]
FROM 
	Warehouse.StockItems AS SI
	JOIN Sales.InvoiceLines AS IL ON SI.StockItemID = IL.StockItemID
	JOIN Sales.Invoices AS I ON IL.InvoiceID = I.InvoiceID
GROUP BY
	SI.StockItemID,
	SI.StockItemName
ORDER BY
	SUM(IL.ExtendedPrice) DESC