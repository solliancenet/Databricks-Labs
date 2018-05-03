$certFile = "C:\Temp\SecureLdapCert.pfx" # this must be an existing folder
$base64certFile = "C:\Temp\SecureLdapCertString.txt"
$certPassword = "Pass@word123"
$domainName = "contoso.com"

$certName = "*." + $domainName # this must match the Azure AD DNS name

$lifetime=Get-Date
$cert = New-SelfSignedCertificate `
    -Subject $certName `
    -NotAfter $lifetime.AddDays(365) `
    -KeyUsage DigitalSignature, KeyEncipherment `
    -Type SSLServerAuthentication `
    -DnsName $certName 
 
$certThumbprint = $cert.Thumbprint
$cert = (Get-ChildItem -Path cert:\LocalMachine\My\$certThumbprint)

$certPasswordSecureString = ConvertTo-SecureString $certPassword -AsPlainText -Force
Export-PfxCertificate -Cert $cert -FilePath $certFile -Password $certPasswordSecureString

$cert=New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certFile, $certPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags] "Exportable, MachineKeySet, PersistKeySet")
$base64cert = [Convert]::ToBase64String($cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $certPassword));
$base64cert | Out-File -FilePath $base64certFile -Force
Get-Content $base64certFile