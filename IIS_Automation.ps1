Configuration Webserver
{

  param (
 
    [string]$port =$(Read-Host -Prompt 'Enter the your website port (default port is 8060)') ,

    [string]$arianwebpath =$(Read-Host -Prompt 'Enter Arianweb installation path (default path is c:\Arianweb)')



    )


  if ([string]::IsNullOrWhiteSpace($port)){
      
        $port = '8060'
         }

  if ([string]::IsNullOrWhiteSpace($arianwebpath)){
      
        $arianwebpath = 'c:\Arianweb'
         }

  Import-DscResource -ModuleName xwebadministration
  Import-DscResource -ModuleName PSDesiredStateConfiguration
  import-dscresource -Name xwebsite


    node localhost {
        #check if server needs to restart
        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }
    # Create a loop to install all IIS Feature
#start loop ...
    foreach ($Feature in @("Web-WebServer","Web-Common-Http","Web-Default-Doc", `
        "Web-Dir-Browsing","Web-Http-Errors","Web-Static-Content","Web-Http-Redirect", `
        "Web-Health","Web-Http-Logging","Web-Performance","Web-Stat-Compression","Web-Security", `
        "Web-Filtering","Web-App-Dev","Web-Net-Ext","Web-Net-Ext45","Web-Asp-Net","Web-Asp-Net45", `
        "Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Mgmt-Tools","Web-Mgmt-Console")){
            
                        WindowsFeature "$Feature"
                        {
                            Ensure = "present"
                            Name = $Feature
                        }}
# ... End loop
        # Create Directory
        File ArianWeb
        {
            Type = 'Directory'
            DestinationPath = $arianwebpath
            Ensure = "Present"
            DependsOn       = "[WindowsFeature]$Feature"
        }

        # Stop the default website
        xWebSite DefaultSite
        {
            Ensure          = 'Present'
            Name            = 'Default Web Site'
            State           = 'Stopped'
            ServerAutoStart = $false
            PhysicalPath    = 'C:\inetpub\wwwroot'
            DependsOn       = "[WindowsFeature]$Feature"
        }

          xWebsite Arianweb
         {
            Ensure          = 'Present'
            Name            = 'Arian'
            State           = 'Started'
            PhysicalPath    = $arianwebpath
            BindingInfo     = @( MSFT_xWebBindingInformation
                                 {
                                   Protocol              = "HTTP"
                                   Port                  = $port
                                 }

                                )
            DependsOn       = '[File]ArianWeb'

         } 
        
    }
}
#create MOF file in Desire path
Webserver -OutputPath "C:\DscConfiguration"
#Running Configuration
Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration"

Start-DscConfiguration -Path 'C:\EnvironmentVariable_Path' -Wait -Verbose	Read MOF file and start configuration


