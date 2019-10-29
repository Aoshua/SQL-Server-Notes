/* Temporal Tables */



https://en.wikipedia.org/wiki/Slowly_changing_dimension








CREATE TABLE dbo.EmployeeExamples(
	EmployeeExampleKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	FullName varchar(255),
	Salary decimal(10,2),
	Department varchar(255),
	SysStartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	SysEndTime datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,  --HIDDEN keeps these extra columns hidden
	PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime)) WITH 
		(SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeExampleHistory, DATA_CONSISTENCY_CHECK = ON)
);

DROP TABLE EmployeeExamples  --Won't work.  









ALTER TABLE [dbo].EmployeeExamples SET ( SYSTEM_VERSIONING = OFF )
GO


INSERT EmployeeExamples (FullName, Salary, Department)
VALUES
	('Russ Reed', 3600, 'Information Technology'),
	('Braxton Reed', 10000, 'Business Intelligence'),
	('Josh Lopez', 10000, 'Talent Solutions'),
	('Eric Barnes', 10000, 'Information Technology')





SELECT * FROM EmployeeExamples





SELECT 
	*,
	SysStartTime,
	SysEndTime

FROM
	EmployeeExamples





UPDATE EmployeeExamples SET SALARY = 7200 WHERE fullname = 'Russ Reed'


SELECT * FROM EmployeeExamples





SELECT 
	*,
	SysStartTime,
	SysEndTime

FROM EmployeeExamples
	FOR SYSTEM_TIME ALL

ORDER BY
	FullName,
	SysEndTime





UPDATE EmployeeExamples SET Department = 'Facilities' WHERE fullname = 'Russ Reed'





SELECT 
	*,
	SysStartTime,
	SysEndTime

FROM EmployeeExamples
	FOR SYSTEM_TIME ALL

ORDER BY
	FullName,
	SysEndTime





SELECT 
	*,
	SysStartTime,
	SysEndTime

FROM EmployeeExamples
	FOR SYSTEM_TIME AS OF '2019-10-22 23:23:12'

ORDER BY
	FullName,
	SysEndTime





SELECT 
	*,
	SysStartTime,
	SysEndTime

FROM EmployeeExamples
	FOR SYSTEM_TIME AS OF '2019-10-22 23:50:12'

ORDER BY
	FullName,
	SysEndTime





https://docs.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables?view=sql-server-ver15