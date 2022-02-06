-- etl_sysjob.sql creates the agent job DWIndependentBookSellersETL
-- Before executing this script, the DWIndependentBookSellers database must be created by running 03_destination_database.

--****************************************  !!! ATTENTION !!!! ***************************************--
-- SQL Server Agent Job DWIndependentBookSellersETL requires the SSIS package execution proxy SSIS_Proxy
-- The PowerShell script New-SSISProxyUser.ps1 can be used to create the SSIS_Proxy credential and proxy
--****************************************************************************************************--

USE msdb
GO

BEGIN TRY
	IF EXISTS (SELECT [name] FROM sysjobs WHERE [name] = 'DWIndependentBookSellersETL')
	BEGIN
		EXEC sp_delete_job @job_name = DWIndependentBookSellersETL;
	END

	BEGIN TRANSACTION;

		DECLARE @ReturnCode INT;
		SELECT @ReturnCode = 0;

		-- Job category
		IF NOT EXISTS (SELECT [name] FROM syscategories WHERE name = N'[Uncategorized (Local)]' AND [category_class] = 1)
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'[Uncategorized (Local)]';

			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
		END

		-- Job ID
		DECLARE @jobId BINARY (16);

		EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'DWIndependentBookSellersETL'
			, @enabled = 1
			, @notify_level_eventlog = 0
			, @notify_level_email = 0
			, @notify_level_netsend = 0
			, @notify_level_page = 0
			, @delete_level = 0
			, @description = N'Performs ETL tasks for DWIndependentBookSellers'
			, @category_name = N'[Uncategorized (Local)]'
			, @owner_login_name = N'sa'
			, @job_id = @jobId OUTPUT;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
		BEGIN
			GOTO QuitWithRollback;
		END

		-- Step(s)
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run DWIndependentBookSellersETLpackage.dtsx'
			, @step_id = 1
			, @cmdexec_success_code = 0
			, @on_success_action = 1
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'SSIS'
			, @command = N'/FILE "\"C:\data_warehouse_demo\data_warehouse_demo_visual_studio_project\Admin\IndependentBookSellersETLpackage.dtsx\"" /CHECKPOINTING OFF /REPORTING E'
			, @database_name = N'master'
			, @flags = 0
			, @proxy_name = N'SSIS_Proxy'; -- https://social.technet.microsoft.com/wiki/contents/articles/36797.sql-credentials-and-proxy-for-agent-job.aspx

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		-- Job Schedule
		EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId
			, @name = N'Recurring Daily 1 AM'
			, @enabled = 1
			, @freq_type = 4
			, @freq_interval = 1
			, @freq_subday_type = 1
			, @freq_subday_interval = 0
			, @freq_relative_interval = 0
			, @freq_recurrence_factor = 0
			, @active_start_date = 20210903
			, @active_end_date = 99991231
			, @active_start_time = 10000
			, @active_end_time = 235959
			, @schedule_uid = N'9640d2e5-225c-454e-b242-0fc720a95597';

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobserver] @job_id = @jobId, @server_name = N'(local)';

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

	COMMIT TRANSACTION;

	GOTO EndSave QuitWithRollback:
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
	EndSave:
END TRY
BEGIN CATCH
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
	PRINT Error_Message()
END CATCH
GO
