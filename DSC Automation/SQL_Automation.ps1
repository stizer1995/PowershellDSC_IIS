#Must be installed with local administrator account
$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}


Configuration SQLInstall
{
      param (
        [Parameter(Mandatory=$true , HelpMessage="Enter SQL Installation Path")]
        [ValidateNotNullOrEmpty()]     
        [string]$SQLserverPath ,

        [Parameter(Mandatory=$true , HelpMessage="Enter SSMS Installation Path with exe path without quotation ex:( c:\ssms\SSMS-Setup-ENU.exe)")]
        [ValidateNotNullOrEmpty()]     
        [string]$SSMSPath ,

        [Parameter(Mandatory=$true , HelpMessage="Enter SQL Data Path")]
        [ValidateNotNullOrEmpty()]     
        [string]$SQL_Data_Path ,

        [Parameter(Mandatory=$true , HelpMessage="Enter setupx.x.x.bak path")]
        [ValidateNotNullOrEmpty()]     
        [string]$Backup_Path ,

        [Parameter(Mandatory=$true , HelpMessage="Enter DatabaseName")]
        [ValidateNotNullOrEmpty()]     
        [string]$DatabaseName ,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$SACredential =$(echo 'SA Password') ,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$ArianCredential =$(echo 'ArianERP Password')
        
        
    
    )


     Import-DscResource -ModuleName SqlServerDsc , PSDesiredStateConfiguration , NetworkingDsc

     node localhost
     {
          # Create Directory
          File 'SQLDataPath'
          {
               Type = 'Directory'
               DestinationPath = $SQL_Data_Path
               Ensure = "Present"
          }

          WindowsFeature 'NetFramework45'
          {
               Name   = 'NET-Framework-45-Core'
               Ensure = 'Present'
          }

          SqlSetup 'InstallArianERPInstance'
          {
               InstanceName        = 'ArianERP'
               Features            = 'SQLENGINE'
               SourcePath          = $SQLserverPath
               SQLSysAdminAccounts = @('Administrator')
               SQLSvcStartupType   = 'Automatic'
               AgtSvcStartupType   = 'Automatic'
               SecurityMode        = 'SQL'
               SAPwd               = $SACredential  
               DependsOn           = '[WindowsFeature]NetFramework45'
          }

          SqlServerNetwork 'SqlStaticTcp' {
               InstanceName = 'ArianERP'
               ProtocolName = 'TCP'
               IsEnabled = $true
               TcpPort = '1433'
               RestartService = $true 
               DependsOn = '[SqlSetup]InstallArianERPInstance'
             }

             Firewall '1433'
             {
                 Name                  = 'Arian-sqlserver-tcp'
                 DisplayName           = 'Arian-sqlserver-tcp'
                 Ensure                = 'Present'
                 Enabled               = 'True'
                 Profile               = ('Domain', 'Private','Public')
                 Direction             = 'Inbound'
                 LocalPort             = '1433'
                 Protocol              = 'TCP'
                 DependsOn = '[SqlServerNetwork]SqlStaticTcp'

             }

             Firewall '1434'
             {
                 Name                  = 'Arian-sqlBrowser-UDP'
                 DisplayName           = 'Arian-sqlBrowser-UDP'
                 Ensure                = 'Present'
                 Enabled               = 'True'
                 Profile               = ('Domain', 'Private','Public')
                 Direction             = 'Inbound'
                 LocalPort             = '1434'
                 Protocol              = 'UDP'
                 DependsOn = '[SqlServerNetwork]SqlStaticTcp'

             }

            SqlScriptQuery 'Restore_raw_Arian.bak'
            {
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            GetQuery             = @'
SELECT Name FROM sys.databases WHERE Name = '$(DatabaseName)' FOR JSON AUTO
'@

            TestQuery            = @'
if (select count(name) from sys.databases where name = '$(DatabaseName)') = 0
BEGIN
    RAISERROR ('Did not find database [$(DatabaseName)]', 16, 1)
END
ELSE
BEGIN
    PRINT 'Found database [$(DatabaseName)]'
END
'@

            SetQuery             = @'
            RESTORE DATABASE $(DatabaseName)
            FROM DISK = N'$(Backup_Path)'
            WITH MOVE 'Beta' TO '$(SQL_Data_Path)\$(DatabaseName)_001.mdf',
            MOVE 'buy' TO '$(SQL_Data_Path)\$(DatabaseName)_002.mdf',
            MOVE 'Common' TO '$(SQL_Data_Path)\$(DatabaseName)_003.mdf',
            MOVE 'Sale' TO '$(SQL_Data_Path)\$(DatabaseName)_004.mdf',
            MOVE 'Acc_' TO '$(SQL_Data_Path)\$(DatabaseName)_005.mdf',
            MOVE 'Inv' TO '$(SQL_Data_Path)\$(DatabaseName)_006.mdf',
            MOVE 'Buy_2' TO '$(SQL_Data_Path)\$(DatabaseName)_007.mdf',
            MOVE 'Trh' TO '$(SQL_Data_Path)\$(DatabaseName)_008.mdf',
            MOVE 'Auto' TO '$(SQL_Data_Path)\$(DatabaseName)_009.mdf',
            MOVE 'Stf' TO '$(SQL_Data_Path)\$(DatabaseName)_010.mdf',
            MOVE 'Sys' TO '$(SQL_Data_Path)\$(DatabaseName)_011.mdf',
            MOVE 'stock' TO '$(SQL_Data_Path)\$(DatabaseName)_012.mdf',
            MOVE 'ast' TO '$(SQL_Data_Path)\$(DatabaseName)_013.mdf',
            MOVE 'KH' TO '$(SQL_Data_Path)\$(DatabaseName)_014.mdf',
            MOVE 'Prod' TO '$(SQL_Data_Path)\$(DatabaseName)_015.mdf',
            MOVE 'Buy_' TO '$(SQL_Data_Path)\$(DatabaseName)_016.mdf',
            MOVE 'Beta_log' TO '$(SQL_Data_Path)\$(DatabaseName)_017.mdf',
            RECOVERY;
'@

            Variable            = "DatabaseName=$DatabaseName" ,"SQL_Data_Path=$SQL_Data_Path" ,"Backup_Path=$Backup_Path"
            QueryTimeout         = 200
            PsDscRunAsCredential = $WindowsCredential
            DependsOn = '[SqlSetup]InstallArianERPInstance' 
        }

        SqlDatabaseUser 'RemoveUser_Arianerp'
        {
            Ensure               = 'Absent'
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            DatabaseName         = $DatabaseName
            Name                 = 'arianerp'

            PsDscRunAsCredential = $WindowsCredential
            DependsOn = '[SqlScriptQuery]Restore_raw_Arian.bak'
        }

        SqlDatabaseUser 'RemoveUser_AS'
        {
            Ensure               = 'Absent'
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            DatabaseName         = $DatabaseName
            Name                 = 'as'

            PsDscRunAsCredential = $WindowsCredential
            DependsOn = '[SqlScriptQuery]Restore_raw_Arian.bak'
        }

        SqlLogin 'Add_ArianERP'
        {
            Ensure                         = 'Present'
            Name                           = 'ArianERP'
            LoginType                      = 'SqlLogin'
            ServerName                     = $env:COMPUTERNAME
            InstanceName                   = 'ArianERP'
            LoginCredential                = $ArianCredential
            LoginMustChangePassword        = $false
            LoginPasswordExpirationEnabled = $false
            LoginPasswordPolicyEnforced    = $false
            PsDscRunAsCredential           = $WindowsCredential
            DependsOn = '[SqlDatabaseUser]RemoveUser_AS'
        }

        SqlScriptQuery 'add server role and user mapping for arianerp in specified database'
        {
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            GetQuery             = 'Set query'

            TestQuery            = 'Test query'
            SetQuery             = @'
        ALTER SERVER ROLE [bulkadmin] ADD MEMBER [ArianERP]
        GO
        ALTER SERVER ROLE [dbcreator] ADD MEMBER [ArianERP]
        GO
        ALTER SERVER ROLE [sysadmin] ADD MEMBER [ArianERP]
        GO
        USE [$(DatabaseName)]
        GO
        CREATE USER [ArianERP] FOR LOGIN [ArianERP]
        GO
       
'@

            Variable            = "DatabaseName=$DatabaseName" 
            QueryTimeout         = 200
            PsDscRunAsCredential = $WindowsCredential
            DependsOn = '[SqlLogin]Add_ArianERP'
         
        }

        SqlScriptQuery 'add server role and user mapping for as'
        {
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            GetQuery             = 'Set query'

            TestQuery            = 'Test query'
            SetQuery             = @'
        
IF NOT EXISTS ( SELECT * FROM master..syslogins WHERE NAME='as')
CREATE LOGIN [as] WITH PASSWORD= 0x0100DF9DC0B91D68BE01427DA76A37D868364E211480E7212A01 HASHED ,DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

exec sp_addsrvrolemember 'as' ,'bulkadmin' 
exec sp_addsrvrolemember 'as' ,'dbcreator' 

DECLARE @DBName NVARCHAR(500)
DECLARE Csr CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
SELECT [Name] FROM sys.databases s
WHERE s.database_id  > 4 AND s.state_desc = 'ONLINE'
OPEN Csr 
FETCH NEXT FROM Csr INTO @DBName
WHILE @@FETCH_STATUS = 0 
BEGIN

EXEC ('USE '+@DBName+' 
        IF NOT EXISTS (SELECT * FROM sysusers
                       WHERE issqlrole = 1 AND NAME=''arian_spexecutor'')
        BEGIN 				
            CREATE ROLE arian_spexecutor 
            GRANT EXECUTE TO arian_spexecutor 
        END
         
       IF NOT EXISTS (SELECT * FROM sysusers
                      where  NAME=''as'')
            CREATE USER [as] FOR LOGIN [as]
 
        EXEC sp_addrolemember N''db_backupoperator'', N''as''
        EXEC sp_addrolemember N''db_datareader'', N''as''
        EXEC sp_addrolemember N''db_datawriter'', N''as''
        EXEC sp_addrolemember N''arian_spexecutor'', N''as''
        EXEC sp_addrolemember N''db_ddladmin'', N''as''
    ')
      
FETCH NEXT FROM Csr INTO @DBName
END	
CLOSE Csr 
DEALLOCATE Csr 


EXEC ('USE MASTER 
  GRANT VIEW SERVER STATE TO [as]')
       
'@

            QueryTimeout         = 200
            PsDscRunAsCredential = $WindowsCredential 
        }

        Package SSMS
        {
             Ensure    = 'Present'   
             Name      = 'Microsoft SQL Server Management Studio - 18.1'
             path      = $SSMSPath
             Arguments  = "/install /passive /norestart"
             productId = '1643af48-a2d8-4806-847c-8d565a9af98a'
             DependsOn = '[SqlSetup]InstallArianERPInstance'  
        }
     }
}
#create MOF file in Desire path
SQLInstall -ConfigurationData $cd -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"