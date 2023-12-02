[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory = $false)][string] $gitHubAccessToken
)

Import-Module (Join-Path $PSScriptRoot 'Common\Common.psm1')

$packageId = 'CologneCodeCompany.XYplorer'
$getVersionUrl = 'https://www.xyplorer.com/version.php'
$getInstallerUrl = 'https://www.xyplorer.com/version.php?installer=1'
$gitHubUsername = 'The-Running-Dev'

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $gitHubAccessToken; $false = $env:GitHubAccessToken }["" -notmatch $gitHubAccessToken]

function Update {
    Exit-WithWarning `
        -Condition (-not $accessToken) `
        -Message 'GitHub Access Token Not Set...Exiting'

    # Install needed modules
    Install-ModuleSafe Microsoft.WinGet.Client
    Install-ModuleSafe PowerShellForGitHub
    <#
    # Setup GitHub connection with the PAT token
    Set-GitHubConnection $gitHubUsername $accessToken

    # Get the current WinGet version of the package
    $winGetVersion = Get-WinGetVersion $packageId

    # Get the latest version
    $latestVersion = Get-ContentFromUrl $getVersionUrl

    # Latest version and WinGet version are the same...
    Exit-WithWarning `
        -Condition ($latestVersion -eq $winGetVersion) `
        -Message "Latest Version ($latestVersion) == WinGet Version ($winGetVersion)...Exiting"

    # Check for existing pull request for this package
    Test-WinGetPullRequest -packageId $packageId

    # Get the installer URL
    $installerUrl = Get-ContentFromUrl $getInstallerUrl

    # Call WinGetCreate to update the version and URL of the package
    Invoke-WinGetUpdate @{
        Id          = $packageId
        Version     = $latestVersion
        Urls        = "$installerUrl|x64|machine"
        AccessToken = $accessToken
    }
    #>
}