[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory = $false)][string] $gitHubAccessToken
)

. (Join-Path $PSScriptRoot 'Common.ps1')

$owner = 'SideQuestVR'
$repository = 'EasyInstallerReleases'
$packageId = 'SideQuestVR.SideQuestEasyInstaller'
$installerRegEx = 'SideQuest-Setup-.*-x64-win.exe$'

$gitHubUsername = 'The-Running-Dev'

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $gitHubAccessToken; $false = $env:GitHubAccessToken }["" -notmatch $gitHubAccessToken]

Exit-WithWarning `
    -Condition (-not $accessToken) `
    -Message 'GitHub Access Token Not Set...Exiting'

# Install needed modules
Install-ModuleSafe Microsoft.WinGet.Client
Install-ModuleSafe PowerShellForGitHub

# Setup GitHub connection with the PAT token
Set-GitHubConnection $gitHubUsername $accessToken

# Get the current WinGet version of the package
$winGetVersion = Get-WinGetVersion $packageId

# Get the latest release from the owner/repository
$release = Get-GitHubReleaseData `
    -Owner $owner `
    -Repository $repository `
    -InstallerRegEx $installerRegEx

# Latest version and WinGet version are the same...
Exit-WithWarning `
    -Condition ($release.Version -eq $winGetVersion) `
    -Message "Latest Version ($($release.Version)) == WinGet Version ($winGetVersion)...Exiting"

# Check for existing pull request for this package
Test-WinGetPullRequest -packageId $packageId

# Call WinGetCreate to update the version and URL of the package
Invoke-WinGetUpdate @{
    Id          = $packageId
    Version     = $release.Version
    Urls        = "$installerUrl $installerUrl"
    AccessToken = $accessToken
}