#Find-Module -Name SqlServerDsc | Install-Module

Configuration SQLIConfiguration
{
      param (
        [Parameter(Mandatory=$true , HelpMessage="Enter SQL Data Path")]
        [ValidateNotNullOrEmpty()]     
        [string]$SQL_Data_Path ,

        [Parameter(Mandatory=$true , HelpMessage="Enter setupx.x.x.bak path")]
        [ValidateNotNullOrEmpty()]     
        [string]$Backup_Path

        [Parameter(Mandatory=$true , HelpMessage="Enter DatabaseName")]
        [ValidateNotNullOrEmpty()]     
        [string]$DatabaseName
    
    
    
    )


     Import-DscResource -ModuleName SqlServerDsc , PSDesiredStateConfiguration

     node localhost
     {
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

            # Variable             = @(
            #     ('DatabaseName={0}' -f $DatabaseName)
            #     ('SQL_Data_Path={0}' -f $SQL_Data_Path)
            # )

            QueryTimeout         = 200

            PsDscRunAsCredential = $WindowsCredential
        }


   

     }
}
#create MOF file in Desire path
SQLIConfiguration -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"