-- maintenance_sysjob.sql creates the agent job DWIndependentBookSellersMaint
-- Before executing this script, the DWIndependentBookSellers database must be created by running 03_destination_database.

USE msdb
GO

BEGIN TRY
	IF EXISTS (SELECT [name] FROM SysJobs WHERE [name] = 'DWIndependentBookSellersMaint')
	BEGIN
		EXEC sp_delete_job @job_name = DWIndependentBookSellersMaint;
	END

	BEGIN TRANSACTION;

		DECLARE @ReturnCode INT;
		SELECT @ReturnCode = 0;

		-- Job category
		IF NOT EXISTS (SELECT [name] FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]' AND category_class = 1)
		BEGIN
			EXEC @ReturnCode = msdb.dbo.[sp_add_category] @class = N'JOB', @type = N'LOCAL', @name = N'[Uncategorized (Local)]';

			IF (@@ERROR <> 0 OR @ReturnCode <> 0 )
			BEGIN
				GOTO QuitWithRollback;
			END
		END

		-- Job ID
		DECLARE @jobId BINARY (16);

		EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'DWIndependentBookSellersMaint'
			, @enabled = 1
			, @notify_level_eventlog = 0
			, @notify_level_email = 0
			, @notify_level_netsend = 0
			, @notify_level_page = 0
			, @delete_level = 0
			, @description = N'Run maintenance tasks on DWIndependentBookSellers'
			, @category_name = N'[Uncategorized (Local)]'
			, @owner_login_name = N'sa'
			, @job_id = @jobId OUTPUT;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		-- Step(s)
		/****** pMaintIndexes ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintIndexes'
			, @step_id = 1
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintIndexes]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintDBBackup ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintDBBackup'
			, @step_id = 2
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintDBBackup]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintRestore ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintRestore'
			, @step_id = 3
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintRestore]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintValidateDimDatesRestore ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintValidateDimDatesRestore'
			, @step_id = 4
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintValidateDimDatesRestore]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintValidateDimAuthorsRestore ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintValidateDimAuthorsRestore'
			, @step_id = 5
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintValidateDimAuthorsRestore]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintValidateDimTitlesRestore ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintValidateDimTitlesRestore'
			, @step_id = 6
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintValidateDimTitlesRestore]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintValidateDimStoresRestore ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintValidateDimStoresRestore'
			, @step_id = 7
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintValidateDimStoresRestore]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0 )
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintValidateFactTitleAuthorsRestore ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintValidateFactTitleAuthorsRestore'
			, @step_id = 8
			, @cmdexec_success_code = 0
			, @on_success_action = 3
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintValidateFactTitleAuthorsRestore]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		/****** pMaintValidateFactSalesRestore ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
			, @step_name = N'Run pMaintValidateFactSalesRestore'
			, @step_id = 9
			, @cmdexec_success_code = 0
			, @on_success_action = 1
			, @on_success_step_id = 0
			, @on_fail_action = 2
			, @on_fail_step_id = 0
			, @retry_attempts = 0
			, @retry_interval = 0
			, @os_run_priority = 0
			, @subsystem = N'TSQL'
			, @command = N'EXEC [dbo].[pMaintValidateFactSalesRestore]'
			, @database_name = N'DWIndependentBookSellers'
			, @flags = 0;

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
			, @name = N'Recurring Daily 2 AM'
			, @enabled = 1
			, @freq_type = 4
			, @freq_interval = 1
			, @freq_subday_type = 1
			, @freq_subday_interval = 0
			, @freq_relative_interval = 0
			, @freq_recurrence_factor = 0
			, @active_start_date = 20210903
			, @active_end_date = 99991231
			, @active_start_time = 20000
			, @active_end_time = 235959
			, @schedule_uid = N'21f924e8-1e0f-49e8-b1e7-be47c9c9d2bd';
		
		IF (@@ERROR <> 0OR @ReturnCode <> 0)
		BEGIN
			GOTO QuitWithRollback;
		END

		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';

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
	PRINT Error_Message();
END CATCH
GO
