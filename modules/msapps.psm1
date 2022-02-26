function New-MakeDirectoryForce([string]$path) {
    # Thanks to raydric, this function should be used instead of `mkdir -force`.
    #
    # While `mkdir -force` works fine when dealing with regular folders, it behaves
    # strange when using it at registry level. If the target registry key is
    # already present, all values within that key are purged.
    if (!(Test-Path $path)) {
        # Write-Host "-- Creating full path to: " $path -ForegroundColor White -BackgroundColor DarkGreen
        New-Item -ItemType Directory -Force -Path $path
    }
}

function Uninstall-StoreApps {
    $WhiteListedApps = @(
        "Microsoft.WindowsStore"
        "Microsoft.MSPaint"
        "Microsoft.Windows.Photos"
        "Microsoft.WindowsCalculator"
        "Microsoft.WindowsCamera"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.MicrosoftEdge.Stable"
        "Microsoft.MicrosoftEdgeDevToolsClient"
    )

    $BlackListedApps = @(
        "Microsoft.BingWeather"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.People"
        "Microsoft.XboxApp"
        "Microsoft.MixedReality.Portal"
        "Microsoft.BingWeather"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.GetHelp"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsAlarms"
        "Microsoft.Getstarted"
    )

    $AllAppPkgs = (Get-AppxPackage -AllUsers).Name

    'Total Installed Apps: ' + $AllAppPkgs.Count
    'List Installed Apps: '
    ForEach($TargetApp in $AllAppPkgs)
    {
        '"' + $TargetApp + '"'
    }

    'Total BlackListed Apps: ' + $BlackListedApps.Count
    ForEach($TargetApp in $BlackListedApps)
    {
        '"' + $TargetApp + '"'
    }

    ForEach($TargetApp in $BlackListedApps)
    {
        "Trying to remove $TargetApp"
        Try
        {
            Get-AppxPackage -Name $TargetApp -AllUsers | Remove-AppxPackage -AllUsers
            Get-AppxPackage -Name $TargetApp | Remove-AppxPackage

            Get-AppXProvisionedPackage -Online |
                Where-Object DisplayName -EQ $TargetApp |
                Remove-AppxProvisionedPackage -Online
        }
        Catch
        {
            Try
            {
                Get-AppxPackage -Name $TargetApp | Remove-AppxPackage

                Get-AppXProvisionedPackage -Online |
                    Where-Object DisplayName -EQ $TargetApp |
                    Remove-AppxProvisionedPackage -Online
            }
            Catch
            {
                $ErrorMessage = $_.Exception.Message
                $sLogOutput = "Non-critical error: Removal of $TargetApp failed, error message is : " + $ErrorMessage
                Write-Output $sLogOutput
            }
        }
    }

    # ForEach($TargetApp in $AllAppPkgs)
    # {
    #     If($WhiteListedApps -notcontains $TargetApp)
    #     {
    #         "Trying to remove $TargetApp"

    #         Try
    #         {
    #             ### DANGEROUS, NOT RECOMMENDED ###
    #             ### Get-AppxPackage -Name $TargetApp -AllUsers | Remove-AppxPackage -AllUsers

    #             ### Get-AppXProvisionedPackage -Online |
    #             ###     Where-Object DisplayName -EQ $TargetApp |
    #             ###     Remove-AppxProvisionedPackage -Online
    #         }
    #         Catch
    #         {
    #             $ErrorMessage = $_.Exception.Message
    #             $sLogOutput = "Non-critical error: Removal of $TargetApp failed" # , error message is : " + $ErrorMessage
    #             Write-Output $sLogOutput
    #         }
    #     }
    # }

    # Prevents Apps from re-installing
    New-MakeDirectoryForce "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "FeatureManagementEnabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "OemPreInstalledAppsEnabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEnabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEverEnabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContentEnabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-314559Enabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0

    # Prevents "Suggested Applications" returning
    New-MakeDirectoryForce "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
}