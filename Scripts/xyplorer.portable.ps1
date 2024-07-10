[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string] $gitHubAccessToken,
    [Parameter()][switch] $skipVersionCheck,
    [Parameter()][switch] $skipPRCheck,
    [Parameter()][switch] $skipSubmit
)

$baseDir = Split-Path $PSScriptRoot -Parent

Import-Module (Join-Path $baseDir 'Common\Common.psm1') -Force

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $gitHubAccessToken; $false = $env:GitHubAccessToken }["" -notmatch $gitHubAccessToken]

$winGetCreateCLISourcePath = Join-Path $baseDir 'Tools\WingetCreateCLI.7z'
$winGetCreateCLIDestinationDir = Join-Path $baseDir 'Tools'

Install-Module 7Zip4PowerShell -Force
Expand-7Zip -ArchiveFileName $winGetCreateCLISourcePath -TargetPath $winGetCreateCLIDestinationDir

Get-WinGetPackageUpdate @{
    PackageId           = 'CologneCodeCompany.XYplorerPortable'
    VersionUrl          = 'https://www.xyplorer.com/version.php'
    WinGetOwner         = $global:WingetRepositoryOwner
    WinGetRepository    = $global:WingetRepositoryName
    GitHubUsername      = $global:gitHubUsername
    AccessToken         = $accessToken
    WinGetCreateCLI     = Join-Path $winGetCreateCLIDestinationDir 'WingetCreateCLI.exe'
    SkipVersionCheck    = $skipVersionCheck.IsPresent
    SkipPRCheck         = $skipPRCheck.IsPresent
    SkipSubmit          = $skipSubmit.IsPresent
} -WhatIf:$WhatIfPreference