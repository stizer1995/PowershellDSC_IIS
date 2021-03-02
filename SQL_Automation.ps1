#Find-Module -Name SqlServerDsc | Install-Module

Configuration SQLInstall
{
      param (
        [Parameter(Mandatory=$true , HelpMessage="Enter SQL Installation Path")]
        [ValidateNotNullOrEmpty()]     
        [string]$SQLserverPath
    
    )


     Import-DscResource -ModuleName SqlServerDsc , PSDesiredStateConfiguration , NetworkingDsc

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
               SQLSvcStartupType = 'Automatic'
               AgtSvcStartupType = 'Automatic'
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

     }
}
#create MOF file in Desire path
SQLInstall -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"