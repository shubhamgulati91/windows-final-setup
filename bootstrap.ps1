# Settings
$repoUri = 'https://github.com/shubhamgulati91/bootstrap-windows-advanced.git'
$setupPath = "./bootstrap-windows-advanced"

Push-Location "/"

# Adjust the execution policy for a programming environment
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force

# Install Chocolately
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# # Boxstarter options
# $Boxstarter.RebootOk=$true # Allow reboots?
# $Boxstarter.NoPassword=$false # Is this a machine with no login password?
# $Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Clean if necessary
if (Test-Path -Path $setupPath) {
    Remove-Item $setupPath -Recurse -Force
}

# Install git
& choco install git --confirm --limit-output

# Reset the path environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

# Clone the setup repository
& git clone $repoUri $setupPath

# Enter inside the repository and invoke the real set-up process
Push-Location $setupPath
Import-Module '.\setup.psm1' -Force

if ($debug -ne $true) {
    # Setup
    Start-Setup
    # Clean Up
    Pop-Location
    Pop-Location
}
