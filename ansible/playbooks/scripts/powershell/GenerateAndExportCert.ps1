# PowerShell Script to Generate and Export a Self-Signed Certificate

# Step 1: Generate the Private Key and Self-Signed Certificate
# This command creates a new self-signed certificate for the specified DNS name.
# The certificate is stored in the local machine's certificate store.
# It is marked as exportable, which means you can export it with its private key.
# The certificate will expire in one year from the creation date.
$dnsName = "snaretraininglab.local"
$certStorePath = "cert:\LocalMachine\My"
$cert = New-SelfSignedCertificate -DnsName $dnsName -CertStoreLocation $certStorePath -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(1)
Write-Host "Certificate generated. Thumbprint: $($cert.Thumbprint)"

# Step 2: Export the Certificate to PFX Format
# Define the path where the PFX file will be stored.
$pfxFilePath = "C:\Path\To\snaretraininglab.local.pfx"
# Create a secure string for the password.
$securePassword = ConvertTo-SecureString -String "yourPFXPassword" -Force -AsPlainText

# Export the certificate to a PFX file with the private key.
Export-PfxCertificate -Cert "$certStorePath\$($cert.Thumbprint)" -FilePath $pfxFilePath -Password $securePassword
Write-Host "Certificate exported to PFX format at: $pfxFilePath"

# Final Output
Write-Host "All operations completed successfully."

# Note:
# Replace "yourPFXPassword" with a secure password of your choice when running the script.
# Adjust the PFX file path as needed to match your storage preferences.
