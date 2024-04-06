[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string] $gitHubAccessToken,
    [Parameter()][switch] $skipVersionCheck,
    [Parameter()][switch] $skipPRCheck,
    [Parameter()][switch] $skipSubmit
)

Import-Module (Join-Path $PSScriptRoot 'Common\Common.psm1') -Force

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $gitHubAccessToken; $false = $env:GitHubAccessToken }["" -notmatch $gitHubAccessToken]

Get-WinGetPackageUpdate @{
    PackageId           = 'CologneCodeCompany.XYplorer'
    VersionUrl          = 'https://www.xyplorer.com/version.php'
    GetInstallerUrl     = 'https://www.xyplorer.com/version.php?installer=1'
    WinGetOwner         = $global:WingetRepositoryOwner
    WinGetRepository    = $global:WingetRepositoryName
    GitHubUsername      = $global:gitHubUsername
    AccessToken         = $accessToken
    SkipVersionCheck    = $skipVersionCheck.IsPresent
    SkipPRCheck         = $skipPRCheck.IsPresent
    SkipSubmit          = $skipSubmit.IsPresent
} -WhatIf:$WhatIfPreference