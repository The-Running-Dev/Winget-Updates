[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string] $gitHubAccessToken,
    [Parameter()][switch] $skipVersionCheck,
    [Parameter()][switch] $skipClone,
    [Parameter()][switch] $skipPRCheck,
    [Parameter()][switch] $skipSubmit
)

Import-Module (Join-Path $PSScriptRoot 'Common\Common.psm1') -Force

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $gitHubAccessToken; $false = $env:GitHubAccessToken }["" -notmatch $gitHubAccessToken]

Update-WithYamlCreate @{
    PackageId               = 'CologneCodeCompany.XYplorerPortable'
    VersionUrl              = 'https://www.xyplorer.com/version.php'
    YamlCreateRepositoryUrl = 'https://github.com/The-Running-Dev/Winget-Packages.git'
    YamlCreateRepositoryDir = Join-Path $PSScriptRoot 'Winget-Packages'
    WinGetOwner             = $global:WingetRepositoryOwner
    WinGetRepository        = $global:WingetRepositoryName
    GitHubUsername          = $global:gitHubUsername
    AccessToken             = $accessToken
    SkipClone               = $skipClone.IsPresent
    SkipVersionCheck        = $skipVersionCheck.IsPresent
    SkipPRCheck             = $skipPRCheck.IsPresent
    SkipSubmit              = $skipSubmit.IsPresent
} -WhatIf:$WhatIfPreference