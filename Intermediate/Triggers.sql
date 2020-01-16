/* ------------
	TRIGGERS:
*/ ------------
--DROP TABLE AuditStuff
CREATE TABLE AuditStuff
(
	AuditKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	AuditRecord varchar(255) NOT NULL,
	AuditDate datetime DEFAULT(GETDATE()) NOT NULL,
	Active bit DEFAULT (1) NOT NULL
)

INSERT AuditStuff (AuditRecord) VALUES ('Some Stuff')

INSERT AuditStuff (AuditRecord) VALUES ('Red Sox')

-------

/* 
Instead of triggers

Runs before the tagged type (DELETE INSERT or UPDATE).  You
	have to do the delete if you want it to occur in this
	type of trigger.	
*/
CREATE OR ALTER TRIGGER InsteadOfDelete  
	--Change to CREATE if first time
ON AuditStuff
INSTEAD OF DELETE
AS
BEGIN
	--DELETE AuditStuff WHERE AuditKey IN 
	--	(SELECT AuditKey FROM deleted)
		--SELECT * FROM deleted
	----OR
	DELETE S
	FROM
		AuditStuff S
		INNER JOIN deleted D ON S.AuditKey = D.AuditKey
END
/* Key point - have to join to the deleted or inserted tables
	or run the risk of not getting all records effected.
*/

-------

SELECT * FROM AuditStuff

DELETE AuditStuff WHERE auditKey = 1

-------

/*
After triggers occur after the tagged event
*/

CREATE OR ALTER TRIGGER AfterInsert
ON AuditStuff
AFTER INSERT
AS
BEGIN
	UPDATE AuditStuff
	SET AuditRecord = i.AuditRecord + ' My Trigger messed this up'
	FROM 
		inserted i
		INNER JOIN AuditStuff S ON I.AuditKey = S.AuditKey

END 
SELECT * FROM AuditStuff
INSERT AuditStuff (AuditRecord) VALUES ('Dodgers Still Suck')


-------

/* An update has access to both special tables.
	The inserted table has the new data, the deleted has the 
	original data
*/
CREATE OR ALTER TRIGGER InsteadOfUpdate
ON AuditStuff
INSTEAD OF UPDATE
AS
BEGIN
	SELECT * from inserted
	SELECT * from deleted
END

SELECT * FROM AuditStuff

UPDATE AuditStuff SET AuditRecord = 'Some Stuff' WHERE auditKey = 4