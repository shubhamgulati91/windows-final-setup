Get-ChildItem .\modules\common.psm1 | Import-Module -Force

function Install-VsCodeExtensionFromUrl([string]$name, [string]$url) {
    Get-DownloadTemporaryFile $name $url {
        & code "--install-extension" $name
    }
}

function Install-VsCodeExtension([string]$name) {
    & code "--install-extension" $name
}

function Restore-VsCodeUserSettings([string]$fileName) {
    $dstPath = Join-Path $env:APPDATA "Code/User"
    $dstFile = Join-Path $dstPath "settings.json"
    New-MakeDirectoryForce $dstPath
    Copy-Item $fileName $dstFile -Force
}
