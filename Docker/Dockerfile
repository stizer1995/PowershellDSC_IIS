FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8
RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\* ;\
  Install-WindowsFeature Web-Dir-Browsing;\
  Install-WindowsFeature Web-Http-Errors;\
  Install-WindowsFeature Web-Static-Content;\
  Install-WindowsFeature Web-Http-Redirect;\
  Install-WindowsFeature Web-Health;\
  Install-WindowsFeature Web-Http-Logging;\
  Install-WindowsFeature Web-Performance;\
  Install-WindowsFeature Web-Stat-Compression;\
  Install-WindowsFeature Web-Security;\
  Install-WindowsFeature Web-Filtering;\
  Install-WindowsFeature Web-App-Dev;\
  Install-WindowsFeature Web-Net-Ext45;\
  Install-WindowsFeature Web-Asp-Net45;\
  Install-WindowsFeature Web-ISAPI-Ext;\
  Install-WindowsFeature Web-ISAPI-Filter;\
  Install-WindowsFeature Web-Common-Http;\
  Install-WindowsFeature Web-WebServer;\
  Install-WindowsFeature Web-Default-Doc;\
  Install-WindowsFeature Web-Mgmt-service;\
  New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force;\
  set-service WMSVC -startuptype Automatic;\
  net start WMSVC ;\
  net user iisadmin Pass123 /ADD;\
  net localgroup administrators iisadmin /add;\
  New-Item c:\dockerfile -type directory ;\
  Remove-WebSite \"Default Web Site\" ;\
  New-Website -Name \"Arian\" -Port 80 -PhysicalPath \"c:\dockerfile\"  ;\
  icacls \"c:\dockerfile\" /grant \"IIS_IUSRS:(F)\" ;\
  icacls \"C:\dockerfile\" /grant \"BUILTIN\IIS_IUSRS:(OI)(CI)F\" /t
WORKDIR /dockerfile
COPY . .