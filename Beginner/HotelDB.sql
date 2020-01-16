--FARMS Creation Script 
--Joshua Abbott 11-20-2018

USE Master

IF EXISTS (SELECT * FROM sysdatabases WHERE name='FARMS_ABBOTT')
DROP DATABASE FARMS_ABBOTT

GO   

CREATE DATABASE FARMS_ABBOTT

ON PRIMARY
(
NAME = 'FARMS_ABBOTT',
FILENAME = 'c:\stage\FARMS_ABBOTT.mdf', 
SIZE = 10MB,
MAXSIZE = 15MB, 
FILEGROWTH = 10%
)

LOG ON 
(
NAME = 'FARMS_ABBOTT_LOG',
FILENAME = 'c:\stage\FARMS_ABBOTT.ldf',
SIZE = 2500KB,
MAXSIZE= 5MB,
FILEGROWTH = 100KB
)

GO

--Create tables for the database:

USE FARMS_ABBOTT

CREATE TABLE GUEST
(
GuestID					smallint		NOT NULL		IDENTITY(1500,1),
GuestFirst     			varchar(20)		NOT NULL,
GuestLast				varchar(20)		NOT NULL,
GuestAddress1  			varchar(30)		NOT NULL,
GuestAddress2			varchar(10),
GuestCity				varchar(20)		NOT NULL,
GuestState				char(2),
GuestPostalCode			char(10)		NOT NULL,
GuestCountry			varchar(20)		NOT NULL,
GuestPhone				varchar(20)		NOT NULL,
GuestEmail				varchar(30),
GuestComments			varchar(200)
)

CREATE TABLE CREDITCARD
(
CreditCardID			smallint		NOT NULL		IDENTITY(1,1),
GuestID     			smallint		NOT NULL,
CCType					varchar(5)		NOT NULL,
CCNumber	  			varchar(16)		NOT NULL,
CCCompany				varchar(40),
CCCardHolder			varchar(40)		NOT NULL,
CCExpiration			smalldatetime	NOT NULL
)

CREATE TABLE RESERVATION
(
ReservationID			smallint		NOT NULL		IDENTITY(5000,1),
ReservationDate     	date			NOT NULL,
ReservationStatus		char(1)			NOT NULL,
ReservationComments		varchar(200),
CreditCardID			smallint		NOT NULL
)

CREATE TABLE FOLIO
(
FolioID					smallint		NOT NULL		IDENTITY(1,1),
ReservationID     		smallint		NOT NULL,
GuestID					smallint		NOT NULL,
RoomID  				smallint		NOT NULL,
QuotedRate				smallmoney		NOT NULL,
CheckinDate				smalldatetime	NOT NULL,
Nights					tinyint			NOT NULL,
Status					char(1)			NOT NULL,
Comments				varchar(200),
DiscountID				smallint		NOT NULL
)

CREATE TABLE DISCOUNT
(
DiscountID				smallint		NOT NULL		IDENTITY(1,1),
DiscountDescription		varchar(50)		NOT NULL,
DiscountEpiration		date			NOT NULL,
DiscountRules			varchar(100),
DiscountPercent			decimal(4,2),
DiscountAmount			smallmoney
)

CREATE TABLE ROOM
(
RoomID					smallint		NOT NULL		IDENTITY(1,1),
RoomNumber     			varchar(5)		NOT NULL,
RoomDescription			varchar(200)	NOT NULL,
RoomSmoking				bit				NOT NULL,
RoomBedConfiguration	char(2)			NOT NULL,
HotelID					smallint		NOT NULL,
RoomTypeID				smallint		NOT NULL
)

CREATE TABLE ROOMTYPE
(
RoomTypeID				smallint		NOT NULL		IDENTITY(1,1),
RTDescription			varchar(200)	NOT NULL
)

CREATE TABLE RACKRATE
(
RackRateID				smallint		NOT NULL		IDENTITY(1,1),
RoomTypeID     			smallint		NOT NULL,
HotelID					smallint		NOT NULL,
RackRate				smallmoney		NOT NULL,
RackRateBegin			date			NOT NULL,
RackRateEnd				date			NOT NULL,
RackRateDescription		varchar(200)	NOT NULL
)

CREATE TABLE HOTEL
(
HotelID					smallint		NOT NULL,
HotelName     			varchar(30)		NOT NULL,
HotelAddress			varchar(30)		NOT NULL,
HotelCity  				varchar(20)		NOT NULL,
HotelState				char(2),
HotelCountry			varchar(20)		NOT NULL,
HotelPostalCode			char(10)		NOT NULL,
HotelStarRating			char(1),
HotelPictureLink		varchar(100),
TaxLocationID			smallint		NOT NULL
)

CREATE TABLE TAXRATE
(
TaxLocationID			smallint		NOT NULL		IDENTITY(1,1),
TaxDescription			varchar(30)		NOT NULL,
RoomTaxRate				decimal(6,4)	NOT NULL,
SalesTaxRAte			decimal(6,4)	NOT NULL
)

CREATE TABLE BILLINGCAREGORY
(
BillingCategoryID		smallint		NOT NULL		IDENTITY(1,1),
BillingCatDescription	varchar(200)	NOT NULL,
BillingCatTaxtable		bit
)

CREATE TABLE BILLING
(
FolioBillingID			smallint		NOT NULL		IDENTITY(1,1),
FolioID     			smallint		NOT NULL,
BillingCategoryID		smallint		NOT NULL,
BillingDescription		char(30)		NOT NULL,
BillingAmount			smallmoney		NOT NULL,
BillingItemQty			tinyint			NOT NULL,
BillingItemDate			date			NOT NULL
)

CREATE TABLE BILLINGCATEGORY
(
BillingCategoryID		smallint		NOT NULL IDENTITY(1,1),
BillingCatDescription	varchar(30)		NOT NULL,
BillingCatTaxable		bit
)

CREATE TABLE PAYMENT
(
PaymentID			smallint		NOT NULL		IDENTITY(8000,1),
FolioID				smallint		NOT NULL,
PaymentDate			date			NOT NULL,
PaymentAmount		smallmoney		NOT NULL,
PaymentComments		varchar(200)
)

--End of table creation

GO
--Add primary keys to tables

ALTER TABLE GUEST
	ADD CONSTRAINT PK_GuestID
	PRIMARY KEY (GuestID)

ALTER TABLE CREDITCARD
	ADD CONSTRAINT PK_CreditCardID
	PRIMARY KEY (CreditCardID)

ALTER TABLE RESERVATION
	ADD CONSTRAINT PK_ReservationID
	PRIMARY KEY (ReservationID)

ALTER TABLE FOLIO
	ADD CONSTRAINT PK_FolioID
	PRIMARY KEY (FolioID)

ALTER TABLE DISCOUNT
	ADD CONSTRAINT PK_DiscountID
	PRIMARY KEY (DiscountID)

ALTER TABLE ROOM
	ADD CONSTRAINT PK_RoomID
	PRIMARY KEY (RoomID)

ALTER TABLE ROOMTYPE
	ADD CONSTRAINT PK_RoomTypeID
	PRIMARY KEY (RoomTypeID)

ALTER TABLE RACKRATE
	ADD CONSTRAINT PK_RackRateID
	PRIMARY KEY (RackRateID)

ALTER TABLE BILLING
	ADD CONSTRAINT PK_FolioBillingID
	PRIMARY KEY (FolioBillingID)

ALTER TABLE BILLINGCATEGORY
	ADD CONSTRAINT PK_BillingCategoryID
	PRIMARY KEY (BillingCategoryID)

ALTER TABLE PAYMENT
	ADD CONSTRAINT PK_PaymentID
	PRIMARY KEY (PaymentID)

ALTER TABLE HOTEL
	ADD CONSTRAINT PK_HotelID
	PRIMARY KEY (HotelID)

ALTER TABLE TAXRATE
	ADD CONSTRAINT PK_TaxLocationID
	PRIMARY KEY (TaxLocationID)
--End of adding primary keys

GO
--Add foreign keys

ALTER TABLE CREDITCARD
	ADD 
	CONSTRAINT FK_CardBelongsToGuest
	FOREIGN KEY (GuestID) REFERENCES GUEST (GuestID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE RESERVATION
	ADD 
	CONSTRAINT FK_ReservationRequiresCard
	FOREIGN KEY (CreditCardID) REFERENCES CREDITCARD (CreditCardID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE FOLIO
	ADD 
	CONSTRAINT FK_FolioIsContainedByReservation
	FOREIGN KEY (ReservationID) REFERENCES RESERVATION (ReservationID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE FOLIO
	ADD 
	CONSTRAINT FK_FolioBelongsToRoom
	FOREIGN KEY (RoomID) REFERENCES ROOM (RoomID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE FOLIO
	ADD 
	CONSTRAINT FK_FolioBelongsToDiscount
	FOREIGN KEY (DiscountID) REFERENCES DISCOUNT (DiscountID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE ROOM
	ADD 
	CONSTRAINT FK_RoomInHotel
	FOREIGN KEY (HotelID) REFERENCES HOTEL (HotelID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE ROOM
	ADD 
	CONSTRAINT FK_RoomIsRoomType
	FOREIGN KEY (RoomTypeID) REFERENCES ROOMTYPE (RoomTypeID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE BILLING
	ADD 
	CONSTRAINT FK_BillingBelongsToFolio
	FOREIGN KEY (FolioID) REFERENCES FOLIO (FolioID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE BILLING
	ADD 
	CONSTRAINT FK_BillingFitsIntoBillingCategory
	FOREIGN KEY (BillingCategoryID) REFERENCES BILLINGCATEGORY (BillingCategoryID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE PAYMENT
	ADD 
	CONSTRAINT FK_PaymentToFolio
	FOREIGN KEY (FolioID) REFERENCES FOLIO (FolioID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE RACKRATE
	ADD 
	CONSTRAINT FK_RackRateGoesWithRoomType
	FOREIGN KEY (RoomTypeID) REFERENCES ROOMTYPE (RoomTypeID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE RACKRATE
	ADD 
	CONSTRAINT FK_RackRateGoesWithHotel
	FOREIGN KEY (HotelID) REFERENCES HOTEL (HotelID)
	ON UPDATE Cascade
	ON DELETE Cascade

ALTER TABLE HOTEL
	ADD 
	CONSTRAINT FK_HotelHasTaxLocation
	FOREIGN KEY (TaxLocationID) REFERENCES TAXRATE (TaxLocationID)
	ON UPDATE Cascade
	ON DELETE Cascade
--End of adding foreign keys

GO
-- Add check constraints:

ALTER TABLE RESERVATION --Provide reservation status constraints: R, A, C, X
	ADD CONSTRAINT CK_ReservationStatus
	CHECK (ReservationStatus IN ('R', 'A', 'C', 'X')) 

ALTER TABLE FOLIO --Provide folio status constraints: R, A, C, X
	ADD CONSTRAINT CK_FolioStatus
	CHECK (Status IN ('R', 'A', 'C', 'X')) 

ALTER TABLE ROOM --Provide bed configuration options: K, Q F, 2Q, 2K, 2F
	ADD CONSTRAINT CK_BedConfig
	CHECK (RoomBedConfiguration IN ('K', 'Q', 'F', '2Q', '2K', '2F')) 

GO
--Add default contraints:
ALTER TABLE FOLIO
	ADD CONSTRAINT DK_DefaultDiscountID		
	DEFAULT 1 FOR DiscountID

GO
--Begin bulk insert

BULK INSERT GUEST FROM 'c:\stage\farms1-1\guest.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT CREDITCARD FROM 'c:\stage\farms1-1\CreditCard.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT FOLIO FROM 'c:\stage\farms1-1\folio.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT BILLING FROM 'c:\stage\farms1-1\billing.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT BILLINGCATEGORY FROM 'c:\stage\farms1-1\billingcategory.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT ROOM FROM 'c:\stage\farms1-1\room.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT ROOMTYPE FROM 'c:\stage\farms1-1\roomtype.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT RACKRATE FROM 'c:\stage\farms1-1\rackrate.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT HOTEL FROM 'c:\stage\farms1-1\hotel.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT TAXRATE FROM 'c:\stage\farms1-1\taxrate.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT PAYMENT FROM 'c:\stage\farms1-1\payment.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT DISCOUNT FROM 'c:\stage\farms1-1\discount.txt' WITH (FIELDTERMINATOR = '|')

BULK INSERT RESERVATION FROM 'c:\stage\farms1-1\reservation.txt' WITH (FIELDTERMINATOR = '|')

--End Bulk insert

GO

USE FARMS_ABBOTT

--Question 1
PRINT 'Beginning #1 - I am inserting myself as a new guest....'

GO
INSERT INTO GUEST
VALUES ('Joshua', 'Abbott', '4373 Westlake Dr.', NULL, 'Roy', 'UT', '84067', 'United States', '801-669-4034', '64josh@gmail.com', 'Listens to music too loud')
GO

PRINT 'Here is the result of the Guest Table after I inserted myself...'

PRINT ''
SELECT * FROM GUEST

--Question 2
PRINT 'Beginning #2 - I am adding a creditcard to go with my guest entry... '

GO
INSERT INTO CREDITCARD
VALUES (@@IDENTITY, 'Visa', '1592648357654852', 'Chase', 'Joshua K. Abbott', '12/08/2022')
GO

PRINT 'Here is the result of the CreditCard Table after I added a new entry...'

PRINT ''
SELECT * FROM CREDITCARD

--Question 3

--Change rackrates:
PRINT 'Beginning #3 - Increasing renovated room rates by 10%'

GO
	UPDATE RACKRATE
	SET RackRate = CEILING(RackRate + (RackRate/10) )
	WHERE RackRateBegin <= GETDATE() AND RackRateEnd >= GETDATE() 
		AND HotelID = 2300
		AND (RoomTypeID = 8 OR RoomTypeID = 9)
GO
PRINT 'Decreasing all other room rates by 10%'
	UPDATE RACKRATE
	SET RackRate = FLOOR(RackRate + (RackRate/10) )
	WHERE RackRateBegin <= GETDATE() AND RackRateEnd >= GETDATE() 
		AND HotelID = 2300
		AND (RoomTypeID <> 8 AND RoomTypeID <> 9)

--Add new coupon:
GO
	INSERT INTO DISCOUNT
	VALUES ('CS 2550 Student Discount', '12/31/2018', 'Must be currently enrolled in CS 2550 at WSU. The stay must be over $200', 0.00 , 25.50)

GO
PRINT 'Here is the result of the RACKRATE Table after I changed the rack rates'

PRINT ''
SELECT * FROM RACKRATE

GO
PRINT 'Here is the result of the DISCOUNT Table after I added the student discount'

PRINT ''
SELECT * FROM DISCOUNT

GO
--Question 4
PRINT 'Beginning #4 - I am writing a select statement to determine the RackRate and nightly tax for room number 302 at Sunridge for any date between Nov 26 and Dec 28'

GO
SELECT RackRate, TAXRATE.RoomTaxRate
FROM RackRate
	JOIN HOTEL ON HOTEL.HotelID = RackRate.HotelID
	JOIN TAXRATE ON TAXRATE.TaxLocationID = HOTEL.TaxLocationID
WHERE HOTEL.HotelName = 'Sunridge Bed & Breakfast'
	AND RackRate.RoomTypeID = (SELECT RoomTypeID FROM ROOM where RoomNumber = 302)
	AND (RackRate.RackRateBegin <= '2018-7-26' AND RackRate.RackRateEnd >= '2018-8-28')

GO
--Question 5
PRINT 'Beginning #5 - I am making myself a master reservation'
INSERT INTO RESERVATION
VALUES ('11/26/2018', 'R', 'No comment',(SELECT CreditCardID
										 FROM CREDITCARD
										 WHERE GuestID = (SELECT GuestID
														  FROM GUEST
														  WHERE (GuestFirst = 'Joshua' AND GuestLast = 'Abbott'))));

PRINT 'Continuing #5 - I am making myself the Nov 26th folio detail'
INSERT INTO FOLIO
VALUES (@@IDENTITY, 1506, 4, 285.00, '11/26/2018', 3, 'R', NULL, 10);

PRINT 'Continuing #5 - I am making myself the Dec 29th folio detail'
INSERT INTO FOLIO
VALUES (5020, 1506, 4, 285.00, '12/28/2018', 3, 'R', NULL, 10);

PRINT ''
PRINT 'Following is the resulting RESERVATION table'
SELECT * FROM RESERVATION

PRINT ''
PRINT 'Following is the resulting FOLIO table'
SELECT * FROM FOLIO

GO
--Question 6
PRINT 'Beginning #6 - I am making a select query for HotelName, RoomNumber, RoomDescription, RackRate'
SELECT HotelName, RoomNumber, RoomDescription, '$' + CAST(RackRate AS varchar(7)) AS 'Rack Rate'
FROM HOTEL
	JOIN ROOM ON HOTEL.HotelID = ROOM.HotelID
	JOIN RACKRATE ON HOTEL.HotelID = RACKRATE.HotelID
WHERE RackRate >= 138.00 
	AND (RACKRATE.RackRateBegin >= '11/1/2018' AND RACKRATE.RackRateBegin <= '12/30/2018')
ORDER BY RackRate;

GO
--Question 7
PRINT 'Beggining #7 - I am listing off hotel name and a count of rooms by floor.'

--Floor 1
SELECT SUBSTRING(HotelName, 1, (CHARINDEX(' ', HotelName + ' ') - 1)) AS 'Hotel Name',
	 SUBSTRING(ROOM.RoomNumber, 1, 1) AS 'Floor Number',
	COUNT(SUBSTRING(ROOM.RoomNumber, 1, 1)) AS 'Number of Rooms on Floor 1'
FROM HOTEL
	JOIN ROOM ON HOTEL.HotelID = ROOM.HotelID
--WHERE SUBSTRING(ROOM.RoomNumber, 1, 1) = 1
GROUP BY HotelName, SUBSTRING(ROOM.RoomNumber, 1, 1)


SELECT HOTEL.HotelName, ROOM.ROOMNUMBER
FROM HOTEL
	JOIN ROOM ON HOTEL.HotelID = ROOM.HotelID

GO

--Question 8
PRINT 'I am making a query to find the total number of arrivals and the average length of stay by hotel name and month'
SELECT HotelName, 

	COUNT(CASE WHEN FOLIO.CheckinDate < '2018-6-01' THEN (FOLIO.CheckinDate) ELSE 0 END) AS 'Average Check-ins in June',
	COUNT(CASE WHEN FOLIO.CheckinDate < '2018-7-01' THEN (FOLIO.CheckinDate) ELSE 0 END) AS 'Average Check-ins in July',
	AVG(CASE WHEN FOLIO.CheckinDate < '2018-6-01' THEN CAST(FOLIO.Nights AS decimal(6,4)) ELSE 0 END) AS 'Average Stay June',
	AVG(CASE WHEN FOLIO.CheckinDate < '2018-7-01' THEN CAST(FOLIO.Nights AS decimal(6,4)) ELSE 0 END) AS 'Average Stay July'
FROM FOLIO
	JOIN ROOM ON FOLIO.RoomID = ROOM.RoomID
	JOIN HOTEL ON ROOM.HotelID = HOTEL.HotelID
GROUP BY HotelName;