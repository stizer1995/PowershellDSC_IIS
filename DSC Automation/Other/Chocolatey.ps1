#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
#Find-Module -Name cchoco | Install-Module -Force
Configuration choco{

    Import-DscResource -ModuleName cChoco

    node $env:COMPUTERNAME{

        cChocoInstaller installChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }
        
        cChocoPackageInstaller dotnetcore-windowshosting
        {
            Name = "dotnetcore-windowshosting"
            DependsOn = "[cChocoInstaller]installChoco"
        }
        
    }   
    }
    #create MOF file in Desire path
    choco -OutputPath "C:\DscConfiguration\choco"
    #Running Configuration
    Start-DscConfiguration -wait -verbose -Path "C:\DscConfiguration\choco"
