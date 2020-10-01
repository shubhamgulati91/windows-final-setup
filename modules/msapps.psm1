function New-MakeDirectoryForce([string]$path) {
    # Thanks to raydric, this function should be used instead of `mkdir -force`.
    #
    # While `mkdir -force` works fine when dealing with regular folders, it behaves
    # strange when using it at registry level. If the target registry key is
    # already present, all values within that key are purged.
    if (!(Test-Path $path)) {
        #Write-Host "-- Creating full path to: " $path -ForegroundColor White -BackgroundColor DarkGreen
        New-Item -ItemType Directory -Force -Path $path
    }
}

function Uninstall-StoreApps {
    $WhiteListedApps = @(
        # Whitelisted Apps
        "Microsoft.WindowsStore"
        "Microsoft.FreshPaint"
        "Microsoft.MSPaint"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.Office.OneNote"
        "Microsoft.OneConnect"
        "Microsoft.Windows.Photos"
        "Microsoft.WindowsCalculator"
        "Microsoft.WindowsCamera"
        "Microsoft.windowscommunicationsapps"
        "Microsoft.WindowsSoundRecorder"

        # Un-installable Apps
        "Microsoft.BioEnrollment"
        "Microsoft.MicrosoftEdge"
        "Microsoft.Windows.Cortana"
        "Microsoft.WindowsFeedback"
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxIdentityProvider"
        "Windows.ContactSupport"
        "Microsoft.Advertising.Xaml"
    )

    $BlackListedApps = @(
        # Default Windows 10 apps
        "Microsoft.3DBuilder"
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingWeather"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MinecraftUWP"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsPhone"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.Xbox.TCUI"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "*holo*"
        "*3dv*"
        "*3db*"
        "*Xbox*"
        
        # Threshold 2 apps
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.WindowsFeedbackHub"

        # Creators Update apps
        #"Microsoft.Microsoft3DViewer"

        #Redstone apps
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingTravel"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.WindowsReadingList"

        # Redstone 5 apps
        "Microsoft.MixedReality.Portal"
        "Microsoft.ScreenSketch"
        #"Microsoft.XboxGamingOverlay"
        "Microsoft.YourPhone"

        # non-Microsoft
        "9E2F88E3.Twitter"
        "PandoraMediaInc.29680B314EFC2"
        "Flipboard.Flipboard"
        "ShazamEntertainmentLtd.Shazam"
        "king.com.CandyCrushSaga"
        "king.com.CandyCrushSodaSaga"
        "king.com.BubbleWitch3Saga"
        "king.com.*"
        "ClearChannelRadioDigital.iHeartRadio"
        "4DF9E0F8.Netflix"
        "6Wunderkinder.Wunderlist"
        "Drawboard.DrawboardPDF"
        "2FE3CB00.PicsArt-PhotoStudio"
        "D52A8D61.FarmVille2CountryEscape"
        "TuneIn.TuneInRadio"
        "GAMELOFTSA.Asphalt8Airborne"
        #"TheNewYorkTimes.NYTCrossword"
        "DB6EA5DB.CyberLinkMediaSuiteEssentials"
        "Facebook.Facebook"
        "flaregamesGmbH.RoyalRevolt2"
        "Playtika.CaesarsSlotsFreeCasino"
        "A278AB0D.MarchofEmpires"
        "KeeperSecurityInc.Keeper"
        "ThumbmunkeysLtd.PhototasticCollage"
        "XINGAG.XING"
        "89006A2E.AutodeskSketchBook"
        "D5EA27B7.Duolingo-LearnLanguagesforFree"
        "46928bounde.EclipseManager"
        "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
        "DolbyLaboratories.DolbyAccess"
        "SpotifyAB.SpotifyMusic"
        "A278AB0D.DisneyMagicKingdoms"
        "*HiddenCityMysteryofShadows*"
        "*AdobePhotoshopExpress*"
        "WinZipComputing.WinZipUniversal"
        "CAF9E577.Plex"  
        "7EE7776C.LinkedInforWindows"
        "613EBCEA.PolarrPhotoEditorAcademicEdition"
        "Fitbit.FitbitCoach"
        "DolbyLaboratories.DolbyAccess"
        "Microsoft.BingNews"
        "NORDCURRENT.COOKINGFEVER"
        "*Dell*"
        "*Dropbox*"
        "*Facebook*"
        "*McAfee*"
    )

    # ForEach($TargetApp in $BlackListedApps)
    # {
    #     "Trying to remove $TargetApp"
    #     Try
    #     {
    #         Get-AppxPackage -Name $TargetApp -AllUsers | Remove-AppxPackage -AllUsers

    #         Get-AppXProvisionedPackage -Online |
    #             Where-Object DisplayName -EQ $TargetApp |
    #             Remove-AppxProvisionedPackage -Online
    #     }
    #     Catch
    #     {
    #         $ErrorMessage = $_.Exception.Message
    #         $sLogOutput = "Non-critical error: Removal of $TargetApp failed" # , error message is : " + $ErrorMessage
    #         Write-Output $sLogOutput
    #     }
    # }

    $AllAppPkgs = (Get-AppxPackage -AllUsers).Name
    'TotalApps: ' + $AllAppPkgs.Count
    'TotalWhiteListedApps: ' + $WhiteListedApps.Count
    'TotalBlackListedApps: ' + ($AllAppPkgs.Count - $WhiteListedApps.Count)
    ForEach($TargetApp in $AllAppPkgs)
    {
        If($WhiteListedApps -notcontains $TargetApp)
        {
            "Trying to remove $TargetApp"

            Try
            {
                Get-AppxPackage -Name $TargetApp -AllUsers | Remove-AppxPackage -AllUsers

                Get-AppXProvisionedPackage -Online |
                    Where-Object DisplayName -EQ $TargetApp |
                    Remove-AppxProvisionedPackage -Online
            }
            Catch
            {
                $ErrorMessage = $_.Exception.Message
                $sLogOutput = "Non-critical error: Removal of $TargetApp failed" # , error message is : " + $ErrorMessage
                Write-Output $sLogOutput
            }
        }
    }

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