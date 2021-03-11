[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

Find-Module -Name xWebAdministration | Install-Module -Force
Find-Module -Name NetworkingDsc | Install-Module -Force
Find-Module -Name sqlserverdsc | Install-Module -Force
Find-Module -Name cchoco | Install-Module -Force