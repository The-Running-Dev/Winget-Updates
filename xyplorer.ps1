[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory = $false)][string] $gitHubAccessToken
)

$packageId = 'CologneCodeCompany.XYplorer'
$getVersionUrl = 'https://www.xyplorer.com/version.php'
$getInstallerUrl = 'https://www.xyplorer.com/version.php?installer=1'

$wingetRepositoryOwner = 'microsoft'
$wingetRepositoryName = 'winget-pkgs'
$wingetRepositoryPullRequestsUrl = 'https://github.com/microsoft/winget-pkgs/pull'

$winGetVersion = '1.0'
$latestVersion = '1.0'
$whatIf = $WhatIfPreference.IsPresent
$gitHubUsername = 'The-Running-Dev'

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $gitHubAccessToken; $false = $env:GitHubAccessToken }["" -notmatch $gitHubAccessToken]

if (-not $accessToken) {
    Write-Warning "`GitHub Access Token Not Set...Exiting"

    return
}

# Install needed modules
if (-not (Get-Module Microsoft.WinGet.Client) -and (-not $whatIf)) {
    Install-Module Microsoft.WinGet.Client -Force
}

if (-not (Get-Module PowerShellForGitHub) -and (-not $whatIf)) {
    Install-Module PowerShellForGitHub -Force
}

# Setup the GitHub module, disable telemetry and set authentication
Set-GitHubConfiguration -DisableTelemetry
$secureString = ($accessToken | ConvertTo-SecureString -AsPlainText -Force)
$credentials = New-Object System.Management.Automation.PSCredential $gitHubUsername, $secureString
Set-GitHubAuthentication -Credential $credentials

# Get the current WinGet version of the package
if ($PSCmdlet.ShouldProcess("-Id $packageId", "Find-WinGetPackage")) {
    $winGetVersion = Find-WinGetPackage -Id $packageId -MatchOption Equals | `
        Select-Object -ExpandProperty version
}

# Get the latest version
if ($PSCmdlet.ShouldProcess($getVersionUrl, "Invoke-WebRequest")) {
    $latestVersion = Invoke-WebRequest $getVersionUrl | Select-Object -ExpandProperty Content
}

# WinGet version does not exist...
if (-not $winGetVersion -and (-not $whatIf)) {
    Write-Warning "Package Does Not Exist on WinGet...Exiting"

    return
}

# Latest version and WinGet version are the same...
if (($latestVersion -eq $winGetVersion) -and (-not $whatIf)) {
    Write-Warning "Latest Version ($latestVersion) == WinGet Version ($winGetVersion)...Exiting"

    return
}

# Get the installer URL
$installerUrl = Invoke-WebRequest $getInstallerUrl | Select-Object -ExpandProperty Content

# Call WinGetCreate to update the version and URL of the package
if ($PSCmdlet.ShouldProcess("$packageId --version $latestVersion --urls '$installerUrl|x64|machine'", "wingetcreate update")) {
    $existingPullRequestId = Get-GitHubPullRequest `
        -OwnerName $wingetRepositoryOwner `
        -RepositoryName $wingetRepositoryName `
        -State Open | `
        Where-Object title -Match $packageId | `
        Select-Object -ExpandProperty id

    if ($existingPullRequestId) {
        Write-Warning "Pull Request Already Exists...$wingetRepositoryPullRequestsUrl/$existingPullRequestId...Exiting"

        return
    }

    & wingetcreate update $packageId `
        --version $latestVersion `
        --urls "$installerUrl|x64|machine" `
        --submit `
        --token $accessToken
}