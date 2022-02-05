-- 07_maintenance_reporting_objects.sql creates a maintenace view that is used in reports.
-- Before executing this script, the DWIndependentBookSellers database must be created by running 03_destination_database.

USE DWIndependentBookSellers;
GO

-- Select * From msdb.dbo.sysjobs;
-- Select * From msdb.dbo.sysjobhistory;
-- EXEC MSDB.dbo.sp_purge_jobhistory;

CREATE OR ALTER VIEW dbo.vDWIndependentBookSellersMaintJobHistory AS (
	SELECT TOP 100000 [JobName] = j.[name]
		, [StepName] = h.[step_name]
		, [RunDateTime] = msdb.dbo.agent_datetime([run_date], [run_time])
		, [RunDurationSeconds] = h.[run_duration]
	FROM msdb.dbo.sysjobs AS j
	INNER JOIN msdb.dbo.sysjobhistory AS h
		ON j.[job_id] = h.[job_id]
		WHERE j.[enabled] = 1
			AND j.[name] = 'DWIndependentBookSellersMaint'
			AND h.[step_name] <> '(Job outcome)'
	ORDER BY 1, 3 DESC
);
GO
