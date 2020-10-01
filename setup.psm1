Get-ChildItem .\modules\*.psm1 | Import-Module -Force
$global:setupPath = (Get-Location).Path

function Start-Setup {
    Write-Output "Beginning the set-up"

    Create-RestorePoint "Before Automated Setup"

    $global:setupPath = (Get-Location).Path

    # Make sure that Git Bash uses colors on Windows
    [System.Environment]::SetEnvironmentVariable("FORCE_COLOR", "true", "Machine")

    # Set-ShellFolders
    Install-UserProfile
    # Install-StartLayout "./configs/start-layout.xml"
    # Install-WindowsDeveloperMode
    Set-DisableAdvertisementsForConsumerEdition $true
    Disable-Telemetry
    # Disable-IntelPowerThrottling
    Set-HidePeopleOnTaskbar $true
    Set-ShowSearchOnTaskbar $false
    # Set-SmallButtonsOnTaskbar $true
    Set-MultiMonitorTaskbarMode "2"
    # Set-DisableWindowsDefender $true
    Set-DarkTheme $true
    # Set-DisableLockScreen $true
    # Set-DisableAeroShake $true
    Set-EnableLongPathsForWin32 $true
    # Set-OtherWindowsStuff
    Remove-3dObjectsFolder #todo
    # Disable-AdministratorSecurityPrompt
    Disable-BingSearchInStartMenu
    Disable-UselessServices
    Disable-EasyAccessKeyboard
    Set-FolderViewOptions
    Uninstall-StoreApps
    # Install-Ubuntu
    Set-ComputerName "ZENBOOK-PRO"

    # This will fail in Windows Sandbox
    @(
        "Printing-XPSServices-Features"
        "Printing-XPSServices-Features"
        "FaxServicesClientPackage"
        "Internet-Explorer-Optional-amd64"
    ) | ForEach-Object { Disable-WindowsOptionalFeature -FeatureName $_ -Online -NoRestart }

    # This will fail in Windows Sandbox
    @(
        #"TelnetClient"
        #"HypervisorPlatform"
        "Microsoft-Hyper-V-All"
        "Containers"
        #"Containers-DisposableClientVM" # Windows Sandbox
        "Microsoft-Windows-Subsystem-Linux"
    ) | ForEach-Object { Enable-WindowsOptionalFeature -FeatureName $_ -Online -NoRestart }

    $chocopkgs = Get-ChocoPackages "./configs/chocopkg.txt"
    Install-ChocoPackages $chocopkgs 1
    Install-ChocoPackages $chocopkgs 2
    Install-ChocoPackages $chocopkgs 3

    # Remove-DesktopIcon
    Remove-HiddenAttribute "/ProgramData"
    Remove-HiddenAttribute (Join-Path $env:USERPROFILE "AppData")

    Install-VsCodeExtensions "./configs/vscode-extensions.txt"
    Restore-VsCodeUserSettings "./configs/vscode-settings.json"

    Get-ChildItem .\modules\common.psm1 | Import-Module -Force
    Get-ChildItem .\modules\*.psm1 | Import-Module -Force
    $global:setupPath = (Get-Location).Path

    # Install Dracula theme for all terminals
    Invoke-TemporaryZipDownload "colortool" "https://github.com/microsoft/terminal/releases/download/1904.29002/ColorTool.zip" {
        $termColorsPath = Join-Path $global:setupPath "configs/Dracula-ColorTool.itermcolors"
        (& ./colortool "-d" "-b" "-x" $termColorsPath)
        
        Set-PSReadlineOption -Color @{
            "Command" = [ConsoleColor]::Green
            "Parameter" = [ConsoleColor]::Gray
            "Operator" = [ConsoleColor]::Magenta
            "Variable" = [ConsoleColor]::White
            "String" = [ConsoleColor]::Yellow
            "Number" = [ConsoleColor]::Blue
            "Type" = [ConsoleColor]::Cyan
            "Comment" = [ConsoleColor]::DarkCyan
        }
    }

    Run-WindowsUpdate
    Remove-TempDirectory
}

function Set-ShellFolders {
    Set-RegistryString "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "Desktop" "D:\Shubham\Desktop"
    Set-RegistryString "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "My Music" "D:\Shubham\Music"
    Set-RegistryString "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "My Pictures" "D:\Shubham\Pictures"
    Set-RegistryString "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "My Video" "D:\Shubham\Video"
    Set-RegistryString "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "Personal" "D:\Shubham\Documents"
    Set-RegistryString "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "{374DE290-123F-4565-9164-39C4925E467B}" "D:\Shubham\Downloads"
}

function Install-VsCodeExtensions([string]$configFileName) {
    Get-Content $configFileName |
        Where-Object { $_[0] -ne '#' -and $_.Length -gt 0 } |
        ForEach-Object {
            Install-VsCodeExtension $_
        }
}

function Remove-DesktopIcon() {
    Remove-Item -Path ((Join-Path $Env:USERPROFILE "Desktop") + "/*.lnk")
    Remove-Item -Path "/Users/Public/Desktop/*.lnk"
}

function Remove-HiddenAttribute([string]$path) {
    Set-ItemProperty $path -Name Attributes -Value Normal
}