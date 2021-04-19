FROM mcr.microsoft.com/windows/servercore/iis
RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\* ;\
  Install-WindowsFeature -Name Web-Mgmt-service;\
  Install-WindowsFeature NET-Framework-45-ASPNET ; \
  New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force;\
  set-service WMSVC -startuptype Automatic;\
  net start WMSVC ;\
  net user iisadmin Pass123 /ADD;\
  net localgroup administrators iisadmin /add;\
  New-Item c:\webapp -type directory ;\
  Remove-WebSite \"Default Web Site\" ;\
  New-Website -Name \"Arian\" -Port 80 -PhysicalPath \"c:\webapp\" -ApplicationPool \".NET v4.5\" ;\
  icacls C:\webapp /grant \"BUILTIN\IIS_IUSRS:(OI)(CI)F\" /t
WORKDIR /webapp
COPY . .