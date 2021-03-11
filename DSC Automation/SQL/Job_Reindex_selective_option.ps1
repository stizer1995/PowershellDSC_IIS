Configuration ReindexJob
{   
    Param
    (
        [Parameter(Mandatory=$true , HelpMessage="Enter DatabaseName")]
        [ValidateNotNullOrEmpty()]     
        [string]$DatabaseName ,

        [string]$Reindex =$(Read-Host -Prompt 'If you want to add Reindex job for this Database , write yes and if you dont want to add reindex
        dont enter anything and hit Enter . ')                                
    )

    Import-DscResource -ModuleName SqlServerDsc , PSDesiredStateConfiguration

    node $env:COMPUTERNAME
    {   
     if (![string]::IsNullOrWhiteSpace($Reindex))
      {
        SqlScriptQuery 'Add Reindex Job'
        {
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            GetQuery             = 'Get query'
            TestQuery            = 'Test query'
            SetQuery             = @'


            DECLARE @Server NVARCHAR(100) = N'$(computername)\ARIANERP' ,
            @DBName	NVARCHAR(100) = '$(DatabaseName)'
            
    DECLARE @str1 NVARCHAR(MAX) = N'
    DECLARE @Str NVARCHAR(MAX) = ''set QUOTED_IDENTIFIER ON 
                                 '' 
    
    SELECT  @Str = @str + 
                '' ALTER INDEX ['' + i.name + ''] On [''+ OBJECT_NAME(f.Object_Id) + ''] ''+ 
                CASE WHEN  avg_fragmentation_in_percent > 30 THEN '' REBUILD  With(FillFactor = 70) ''
                ELSE '' REORGANIZE ''
                END  	
        FROM sys.dm_db_index_physical_stats(DB_ID('''+@DBName+''') ,0 ,-1 ,0 ,''limited'') f
        inner JOIN sys.indexes i ON i.index_id = f.index_id AND i.[object_id] = f.[object_id]
        inner join sys.tables t on t.object_id = f.object_id
        WHERE avg_fragmentation_in_percent >= 5 and i.type_desc <> ''Heap''
            and t.filestream_data_space_id is  null 
        
    exec( @Str )'		
    
    USE [msdb]
    
    DECLARE @jobId BINARY(16)
    EXEC  msdb.dbo.sp_add_job @job_name=N'ReIndex', 
            @enabled=1, 
            @notify_level_eventlog=0, 
            @notify_level_email=2, 
            @notify_level_page=2, 
            @delete_level=0, 
            @category_name=N'[Uncategorized (Local)]', 
            @owner_login_name=N'Arianerp', @job_id = @jobId OUTPUT
    
    EXEC msdb.dbo.sp_add_jobserver @job_name=N'ReIndex', @server_name = @Server
    
    EXEC msdb.dbo.sp_add_jobstep @job_name=N'ReIndex', @step_name=N'Index', 
            @step_id=1, 
            @cmdexec_success_code=0, 
            @on_success_action=3, 
            @on_fail_action=3, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=@str1, 
            @database_name=@DBName, 
            @flags=0
            
    EXEC msdb.dbo.sp_add_jobstep @job_name=N'ReIndex', @step_name=N'Stat', 
            @step_id=2, 
            @cmdexec_success_code=0, 
            @on_success_action=3, 
            @on_fail_action=3, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=N'DECLARE @Str NVARCHAR(MAX) = '''' 
    
    SELECT @str = @str + '' Update Statistics [''+obj.name + ''] [''+ stat.name + ''] With FULLSCAN ''+CHAR(13)  
    FROM sys.objects AS obj   
    INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id  
    CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp  
    WHERE modification_counter > 100  
    AND obj.type_desc <> ''SYSTEM_TABLE'' and obj.type <> ''IT''
    
    EXEC( @Str )', 
            @database_name=@DBName, 
            @flags=0
            
    EXEC msdb.dbo.sp_add_jobstep @job_name=N'ReIndex', @step_name=N'Common', 
            @step_id=3, 
            @cmdexec_success_code=0, 
            @on_success_action=1, 
            @on_fail_action=2, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=N'DBCC SHRINKFILE (beta_log ,64)
    
    go
    
    dbcc freeproccache', 
            @database_name=@DBName, 
            @flags=0
            
    EXEC msdb.dbo.sp_update_job @job_name=N'ReIndex', 
            @enabled=1, 
            @start_step_id=1, 
            @notify_level_eventlog=0, 
            @notify_level_email=2, 
            @notify_level_page=2, 
            @delete_level=0, 
            @description=N'', 
            @category_name=N'[Uncategorized (Local)]', 
            @owner_login_name=N'Arianerp', 
            @notify_email_operator_name=N'', 
            @notify_page_operator_name=N''
            
    DECLARE @schedule_id int
    EXEC msdb.dbo.sp_add_jobschedule @job_name=N'ReIndex', @name=N't1', 
            @enabled=1, 
            @freq_type=4, 
            @freq_interval=1, 
            @freq_subday_type=1, 
            @freq_subday_interval=0, 
            @freq_relative_interval=0, 
            @freq_recurrence_factor=1, 
            @active_start_date=20190508, 
            @active_end_date=99991231, 
            @active_start_time=230000, 
            @active_end_time=235959, @schedule_id = @schedule_id OUTPUT    
'@
            Variable            = "computername=$env:COMPUTERNAME" , "DatabaseName=$DatabaseName"
            QueryTimeout         = 200
            PsDscRunAsCredential = $WindowsCredential
        }  
      }

    }
}

#create MOF file in Desire path
Reindexjob -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"