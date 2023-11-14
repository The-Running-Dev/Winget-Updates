$owner = 'SideQuestVR'
$repository = 'EasyInstallerReleases'
$packageId = 'SideQuestVR.SideQuestEasyInstaller'
$installerRegEx = 'SideQuest-Setup-.*-x64-win.exe$'
$gitHubUsername = 'The-Running-Dev'

# Install needed modules
Install-Module Microsoft.WinGet.Client -Force
Install-Module PowerShellForGitHub -Force

# Setup the GitHub module, disable telemetry and set authentication
Set-GitHubConfiguration -DisableTelemetry
#$secureString = (${{secrets.PublicToken} } | ConvertTo-SecureString -AsPlainText -Force)
#$credentials = New-Object System.Management.Automation.PSCredential $gitHubUsername, $secureString
#Set-GitHubAuthentication -Credential $credentials

# Get the current WinGet version of the package
$winGetVersion = Find-WinGetPackage -Id $packageId | `
    Select-Object -ExpandProperty version

# Get the latest release from the owner/repository
$release = Get-GitHubRelease `
    -OwnerName $owner `
    -RepositoryName $repository `
    -Latest
$latestVersion = $release.tag_name -replace 'v', ''

# Latest version and WinGet version are the same...
if ($latestVersion -eq $winGetVersion) {
    Write-Host "Released Version ($latestVersion) == WinGet Version ($winGetVersion)...Exiting"
    return
}

# Get the installer download URL
$downloadUrl = $release.assets | `
    Where-Object name -Match $installerRegEx | `
    Select-Object -ExpandProperty browser_download_url
<#
# Call WinGetCreate to update the version and URL of the package
& wingetcreate update $packageId `
    --urls '$downloadUrl' '$downloadUrl' `
    --version $version `
    --submit `
    --token ${{secrets.PublicToken} }
#>