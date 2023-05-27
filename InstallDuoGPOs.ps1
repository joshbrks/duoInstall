#Download from source URL
$url = "https://dl.duosecurity.com/DuoWinLogon_MSIs_Policies_and_Documentation-latest.zip"
$outFile = "C:\temp\DuoGPO.zip"
Invoke-WebRequest -Uri $url -OutFile $outFile
Expand-Archive $outFile -DestinationPath "C:\temp\DUO"

#Copy to PolicyDefinitions
Copy-Item -Path "C:\temp\DUO\DuoWindowsLogon.adml" -Destination "C:\Windows\SYSVOL\sysvol\$env:USERDNSDomain\Policies\PolicyDefinitions\en-US"
Copy-Item -Path "C:\temp\DUO\DuoWindowsLogon.admx" -Destination "C:\Windows\SYSVOL\sysvol\$env:USERDNSDomain\Policies\PolicyDefinitions\"

#Copy DUO Installer and create SMD shared folder
Copy-Item -Path "C:\temp\DUO\DuoWindowsLogon64.msi" -Destination "C:\DUO\"
New-Item -Path "C:\DUO" -ItemType Directory
$Parameters = @{
    Name = 'DUO'
    Path = 'C:\DUO'
    FullAccess = 'Administrators'
    ReadAccess = 'Domain Computers', 'Domain Controllers'
}
New-SmbShare @Parameters

#Create DUO GPOs
New-GPO -Name "Duo-Windows Logon"
New-GPO -Name "Duo-Installation"

Write-Host "Go ahead and begin editing the GPOs created, and link them to the domain." -ForegroundColor Green
pause

#Download AD Directory Sync
$url = "https://dl.duosecurity.com/duoauthproxy-latest.exe"
$outFile = "C:\temp\DuoAuthProxy.exe"
Invoke-WebRequest -Uri $url -OutFile $outFile
Start-Process -FilePath C:\temp\DuoAuthProxy.exe /S
Remove-Item "C:\Program Files\Duo Security Authentication Proxy\conf\authproxy.cfg"
Invoke-Item "C:\Program Files\Duo Security Authentication Proxy\conf"
Write-Host "ADD WINDOWS AD DIRECTORY SYNC..." -ForegroundColor Green
Write-Host "Drop in the configuration file into the window that popped up." -ForegroundColor Green
Write-Host "Continue once ready to start the Application Proxy." -ForegroundColor Green
pause
Start-Process -FilePath "C:\Program Files\Duo Security Authentication Proxy\bin\local_proxy_manager-win32-x64\Duo_Authentication_Proxy_Manager.exe"
ipconfig
