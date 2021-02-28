#Find-Module -Name SqlServerDsc | Install-Module

Configuration SQLInstall
{
      param (
        [Parameter(Mandatory=$true , HelpMessage="Enter SQL Installation Path")]
        [ValidateNotNullOrEmpty()]     
        [string]$SQLserverPath
    
    )


     Import-DscResource -ModuleName SqlServerDsc,PSDesiredStateConfiguration

     node localhost
     {
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
               SQLSysAdminAccounts = @('Administrators')
               DependsOn           = '[WindowsFeature]NetFramework45'
          }
     }
}
#create MOF file in Desire path
SQLInstall -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"