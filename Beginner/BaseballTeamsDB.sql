--Baseball Team Creation Script 
--Joshua Abbott 09-26-2018

USE Master

IF EXISTS (SELECT * FROM sysdatabases WHERE name='Abbott_Baseball')
DROP DATABASE Abbott_Baseball

GO   

CREATE DATABASE Abbott_Baseball

ON PRIMARY --Primary/singular partition
(
NAME = 'Abbott_Baseball',
FILENAME = 'c:\stage\Abbott_Baseball.mdf', 
SIZE = 10MB,
MAXSIZE = 15MB, 
FILEGROWTH = 10% --Not sure if you want us to include the growth as in the example
)

LOG ON

(
NAME = 'Abbott_Baseball_Log',
FILENAME = 'c:\stage\Abbott_Baseball.ldf',
SIZE = 2500KB, --25% so it is safe for read AND write
MAXSIZE= 5MB, --I had to bump this up a little to fit in all the tables
FILEGROWTH = 100KB
) 

GO

--Create tables for the database:

USE Abbott_Baseball

CREATE TABLE Team
(
TeamID					smallint		NOT NULL		IDENTITY(1,1),
TeamName     			varchar(50)		NOT NULL,
TeamCity				varchar(50)		NOT NULL,
TeamManager  			varchar(50)		NOT NULL
)

CREATE TABLE Bat
(
BatSerialNumber			smallint		NOT NULL		IDENTITY(1,1),
BatManufactuter			varchar(50)		NOT NULL,
TeamID					smallint		NOT NULL
)

CREATE TABLE Coach
(
CoachID					smallint		NOT NULL		IDENTITY(1,1),
CoachName     			varchar(30)		NOT NULL,
CoachPhoneNumber		varchar(20)		NOT NULL,
CoachUnits  			smallint		NOT NULL,
TeamID					smallint		NOT NULL
)

CREATE TABLE UnitsOfWork
(
UnitsNumber				smallint		NOT NULL		IDENTITY(1,1),
NumberOfYears     		smallint		NOT NULL,
ExperienceType			nvarchar(30)	NOT NULL,
CoachID  				smallint		NOT NULL
)

CREATE TABLE PlayerHistory
(
PlayerHistoryID			smallint		NOT NULL		IDENTITY(1,1),
TeamID     				smallint		NOT NULL,
PlayerID				smallint		NOT NULL,
PlayerBatingAverage  	smallint		NOT NULL,
PlayerStartDate			smalldatetime	NOT NULL,
PlayerEndDate			smalldatetime	NOT NULL,
PlayerPosition			nvarchar(10)	NOT NULL
)

CREATE TABLE Player
(
PlayerID				smallint		NOT NULL		IDENTITY(1,1),
PlayerName     			nvarchar(30)	NOT NULL,
PlayerAge				smallint		NOT NULL
)

--End of table creation

GO
-- Alter each of the tables to add Primary keys

ALTER TABLE Team
	ADD CONSTRAINT PK_TeamID
	PRIMARY KEY (TeamID)
	
ALTER TABLE Bat
	ADD CONSTRAINT PK_BatSerialNumber
	PRIMARY KEY (BatSerialNumber)

ALTER TABLE Coach
	ADD CONSTRAINT PK_CoachID
	PRIMARY KEY (CoachID)
	
ALTER TABLE UnitsOfWork
	ADD CONSTRAINT PK_UnitsNumber
	PRIMARY KEY (UnitsNumber)

ALTER TABLE PlayerHistory
	ADD CONSTRAINT PK_PlayerHistoryID
	PRIMARY KEY (PlayerHistoryID)
	
ALTER TABLE Player
	ADD CONSTRAINT PK_PlayerID
	PRIMARY KEY (PlayerID)

--End of primary key alters

GO
-- Alter tables to set up foreign keys

ALTER TABLE Bat
	ADD 
	
	CONSTRAINT FK_BatBelongsToTeam
	FOREIGN KEY (TeamID) REFERENCES Team (TeamID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE Coach
	ADD 
	
	CONSTRAINT FK_CoachWorksOnTeam
	FOREIGN KEY (TeamID) REFERENCES Team (TeamID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE UnitsOfWork
	ADD 
	
	CONSTRAINT FK_UnitsOfWorkBelongsToCoach
	FOREIGN KEY (CoachID) REFERENCES Coach (CoachID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE PlayerHistory
	ADD 
	
	CONSTRAINT FK_PlayerHistoryBelongsToTeam
	FOREIGN KEY (TeamID) REFERENCES Team (TeamID)
	ON UPDATE Cascade
	ON DELETE Cascade,

	CONSTRAINT FK_PlayerHistoryBelongsToPlayer
	FOREIGN KEY (PlayerID) REFERENCES Player (PlayerID)
	ON UPDATE Cascade
	ON DELETE Cascade

-- end of foreign keys

GO
-- Add check constraints

ALTER TABLE Player
	ADD CONSTRAINT CK_PlayerAge
	CHECK (PlayerAge >= 18) --check that player is an adult
	
-- ensures that a ship is built in the 21st century
ALTER TABLE Bat
	ADD CONSTRAINT CK_BatManufactuter
	CHECK (BatManufactuter IN ('Easton', 'Louisville', 'Marucci', 'Rawlings', 'DeMarini'))

ALTER TABLE PlayerHistory
	ADD CONSTRAINT CK_PlayerBatingAverage
	CHECK (PlayerBatingAverage > 0.2) --Must have a batting average above 0.2 to be pro

--end of check constraints

GO
--Add default constraints
	
ALTER TABLE PlayerHistory
	ADD CONSTRAINT DK_DefaultPlayerPosition		
	DEFAULT 'Outfielder' FOR PlayerPosition

ALTER TABLE Player
	ADD CONSTRAINT DK_DefaultPlayerAge	
	DEFAULT 29 FOR PlayerAge
--End of default constraints

--DROP DATABASE Abbott_Baseball
