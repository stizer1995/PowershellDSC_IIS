#Find-Module -Name SqlServerDsc | Install-Module

Configuration SSMSInstall
{
      param (
        [Parameter(Mandatory=$true , HelpMessage="Enter SSMS Installation Path with exe path without quotation ex:( c:\ssms\SSMS-Setup-ENU.exe)")]
        [ValidateNotNullOrEmpty()]     
        [string]$SSMSPath
    
    )


     node localhost
     {
          Package SSMS
          {
               Ensure    = 'Present'   
               Name      = 'Microsoft SQL Server Management Studio - 18.1'
               path      = $SSMSPath
               Arguments  = "/install /passive /norestart"
               productId = '1643af48-a2d8-4806-847c-8d565a9af98a'
               
          }


     }
}
#create MOF file in Desire path
SSMSInstall -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"




