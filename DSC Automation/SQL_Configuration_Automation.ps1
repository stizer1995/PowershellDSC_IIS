#Find-Module -Name SqlServerDsc | Install-Module

Configuration SQLIConfiguration
{

    param (
        [Parameter(Mandatory=$true , HelpMessage="Enter DatabaseName")]
        [ValidateNotNullOrEmpty()]     
        [string]$DatabaseName
    
    
    
    )


     Import-DscResource -ModuleName SqlServerDsc , PSDesiredStateConfiguration

     node localhost
     {
        SqlDatabaseUser 'RemoveUser_Arianerp'
        {
            Ensure               = 'Absent'
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            DatabaseName         = $DatabaseName
            Name                 = 'arianerp'

            PsDscRunAsCredential = $WindowsCredential
        }

        SqlDatabaseUser 'RemoveUser_AS'
        {
            Ensure               = 'Absent'
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'ArianERP'
            DatabaseName         = $DatabaseName
            Name                 = 'as'

            PsDscRunAsCredential = $WindowsCredential
        }

     }
}
#create MOF file in Desire path
SQLIConfiguration -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"