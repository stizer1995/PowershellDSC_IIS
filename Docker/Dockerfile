FROM mcr.microsoft.com/windows/servercore/iis

SHELL [ "powershell" ]

RUN Remove-Item -Recurse C:\inetpub\wwwroot\* ;\
Install-WindowsFeature -Name Web-Mgmt-Tools;\
Install-WindowsFeature -Name Web-WebServer;\
Install-WindowsFeature -Name Web-Common-Http;\
Install-WindowsFeature -Name Web-Default-Doc;\
Install-WindowsFeature -Name Web-Dir-Browsing;\
Install-WindowsFeature -Name Web-Http-Errors;\
Install-WindowsFeature -Name Web-Static-Content;\
Install-WindowsFeature -Name Web-Http-Redirect;\
Install-WindowsFeature -Name Web-Health;\
Install-WindowsFeature -Name Web-Http-Logging;\
Install-WindowsFeature -Name Web-Performance;\
Install-WindowsFeature -Name Web-Stat-Compression;\
Install-WindowsFeature -Name Web-Security;\
Install-WindowsFeature -Name Web-Filtering;\
Install-WindowsFeature -Name Web-App-Dev;\
Install-WindowsFeature -Name Web-Net-Ext;\
Install-WindowsFeature -Name Web-Net-Ext45;\
Install-WindowsFeature -Name Web-Asp-Net;\
Install-WindowsFeature -Name Web-Asp-Net45;\
Install-WindowsFeature -Name Web-ISAPI-Ext;\
Install-WindowsFeature -Name Web-ISAPI-Filter;\
Install-WindowsFeature -Name Web-Mgmt-Console;\
  New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force;\
  set-service WMSVC -startuptype Automatic;\
  net start WMSVC ;\
   net user iisadmin Pass123 /ADD;\
    net localgroup administrators iisadmin /add;\
    #create new website
    New-Item c:\webapp -type directory;\
   Remove-WebSite -Name "Default Web Site";\
   New-Website -Name 'Arian' -Port 80 -PhysicalPath 'c:\webapp' -ApplicationPool '.NET v4.5';\
   icacls 'C:\webapp' /grant 'IIS_IUSRS:(F)'


WORKDIR /inetpub/wwwroot

COPY . c:\webapp