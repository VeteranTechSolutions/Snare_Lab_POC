# Enable the SSH server feature if not already enabled
Write-Host "Checking if OpenSSH server is installed..."

$feature = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH.Server*' }

if ($feature.State -ne 'Installed') {
    Write-Host "OpenSSH server is not installed. Installing..."
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Write-Host "OpenSSH server installed successfully."
} else {
    Write-Host "OpenSSH server is already installed."
}

# Start the SSH server service
Write-Host "Starting the OpenSSH server service..."
Start-Service -Name 'sshd'

# Enable the SSH server service to start automatically on boot
Write-Host "Enabling the OpenSSH server service to start on boot..."
Set-Service -Name 'sshd' -StartupType 'Automatic'

# Verify the status of the SSH server service
$serviceStatus = Get-Service -Name 'sshd'
Write-Host "The SSH server service is currently: $($serviceStatus.Status)"
Write-Host "OpenSSH server setup complete."