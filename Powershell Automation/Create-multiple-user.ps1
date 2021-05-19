# Script based on http://stackoverflow.com/questions/383390/create-local-user-with-powershell-windows-vista
# Creates 30 users that are administrators and belong to the Remote Desktop Users group.

function create-account ([string]$accountName) {
    #specify your Hostname
    $hostname = $env:COMPUTERNAME
    $comp = [adsi]"WinNT://$hostname"
    $user = $comp.Create("User", $accountName)
    $user.SetPassword("Pass123")
    $user.SetInfo()
    $User.UserFlags[0] = $User.UserFlags[0] -bor 0x10000 #ADS_UF_DONT_EXPIRE_PASSWD flag is 0x10000
    $user.SetInfo()
   
    # $objOU = [ADSI]"WinNT://$hostname/Administrators,group"
    # $objOU.add("WinNT://$hostname/$accountName")
   
    $objOU = [ADSI]"WinNT://$hostname/Remote Desktop Users,group"
    $objOU.add("WinNT://$hostname/$accountName")
   }
   
   # Create 30 administrator users named user1 ... user 30
   for($i=1; $i -le 10; $i++){
     create-account("user$i")
   }