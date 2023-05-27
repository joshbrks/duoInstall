#Download from source URL
$url = "https://download.microsoft.com/download/8/d/d/8ddd685d-7d55-42e2-9555-6ab365050734/Administrative%20Templates%20(.admx)%20for%20Windows%2011%20September%202022%20Update.msi"
$outFile = "C:\temp\AdmxTemplates.msi"
Invoke-WebRequest -Uri $url -OutFile $outFile

#Run downloaded MSI
$arguments = "/i `"$outFile`" /qb"
Start-Process msiexec.exe -ArgumentList $arguments -Wait

#Copy to PolicyDefinitions
Copy-Item -Path "C:\Windows\PolicyDefinitions\" -Destination "C:\Windows\SYSVOL\sysvol\$env:USERDNSDomain\Policies\PolicyDefinitions" -Recurse