#Download from source URL
$url = "https://dl.duosecurity.com/DuoWinLogon_MSIs_Policies_and_Documentation-latest.zip"
$outFile = "C:\temp\DuoGPO.zip"
Invoke-WebRequest -Uri $url -OutFile $outFile
Expand-Archive $outFile -DestinationPath "C:\temp\DUO"

Write-Host "Creating Duo GPOs templates..." -ForegroundColor Green
Start-Sleep 2
#Copy to PolicyDefinitions
Copy-Item -Path "C:\temp\DUO\DuoWindowsLogon.adml" -Destination "C:\Windows\SYSVOL\sysvol\$env:USERDNSDomain\Policies\PolicyDefinitions\en-US"
Copy-Item -Path "C:\temp\DUO\DuoWindowsLogon.admx" -Destination "C:\Windows\SYSVOL\sysvol\$env:USERDNSDomain\Policies\PolicyDefinitions\"
#Create DUO GPOs
New-GPO -Name "Duo-Windows Logon"
New-GPO -Name "Duo-Installation"

#Copy DUO Installer and create SMD shared folder
Write-Host "Creating Duo SMB Share..." -ForegroundColor Green
Start-Sleep 2
New-Item -Path "C:\DUO" -ItemType Directory
$Parameters = @{
    Name = 'DUO'
    Path = 'C:\DUO'
    FullAccess = 'Administrators'
    ReadAccess = 'Domain Computers', 'Domain Controllers'
}
New-SmbShare @Parameters
Copy-Item -Path "C:\temp\DUO\DuoWindowsLogon64.msi" -Destination "C:\DUO\"

#Download AD Directory Sync
Write-Host "Starting AD Directory Sync setup..." -ForegroundColor Green
Start-Sleep 2
$url = "https://dl.duosecurity.com/duoauthproxy-latest.exe"
$outFile = "C:\temp\DuoAuthProxy.exe"
Invoke-WebRequest -Uri $url -OutFile $outFile
Start-Process -FilePath C:\temp\DuoAuthProxy.exe /S
Remove-Item "C:\Program Files\Duo Security Authentication Proxy\conf\authproxy.cfg"
Invoke-Item "C:\Program Files\Duo Security Authentication Proxy\"

Write-Host "Drop in the configuration file into the window that popped up, and make sure it's named 'authproxy.cfg' under the CONF folder." -ForegroundColor Yellow
pause
Start-Process -FilePath "C:\Program Files\Duo Security Authentication Proxy\bin\local_proxy_manager-win32-x64\Duo_Authentication_Proxy_Manager.exe"
Write-Host "Enter the following IP address into the Duo Admin Portal"
ipconfig
Pause

#Reveal DN
Write-Host "When you're ready to grab the Distinguished Name, press enter." -BackgroundColor Yellow -ForegroundColor Black
pause
$filter = "(&(objectCategory=computer)(objectClass=computer)(cn=$env:COMPUTERNAME))"
$dn = ([adsisearcher]$filter).FindOne().Properties.distinguishedname
Write-Host "DN:   $($dn)" -ForegroundColor Cyan

#Wait for user confirmation to continue
Write-Host "When you're ready to edit the MSI file, press enter." -BackgroundColor Yellow -ForegroundColor Black
pause

#Download Orca
$url = "https://www.technipages.com/downloads/OrcaMSI.zip"
$outFile = "C:\temp\Orca.zip"
Invoke-WebRequest -Uri $url -OutFile $outFile
Expand-Archive $outFile -DestinationPath "C:\temp\DUO"

#Run downloaded MSI for Orca
$arguments = "/i `"C:\temp\DUO\Orca.msi`" /qb"
Start-Process msiexec.exe -ArgumentList $arguments -Wait

$ps = new-object System.Diagnostics.Process  
$ps.StartInfo.Filename = "C:\Program Files (x86)\Orca\Orca.exe"  
$ps.StartInfo.Arguments = "C:\DUO\DuoWindowsLogon64.msi"  
$ps.start()