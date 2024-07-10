[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string] $gitHubAccessToken,
    [Parameter()][switch] $skipVersionCheck,
    [Parameter()][switch] $skipPRCheck,
    [Parameter()][switch] $skipSubmit
)

$baseDir = Split-Path $PSScriptRoot -Parent

Import-Module (Join-Path $baseDir 'Common\Common.psm1') -Force
Install-ModuleSafe 7Zip4PowerShell

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $gitHubAccessToken; $false = $env:GitHubAccessToken }["" -notmatch $gitHubAccessToken]

$winGetCreateCLISourcePath = Join-Path $baseDir 'Tools\WingetCreateCLI.7z'
$winGetCreateCLIDestinationPath = Join-Path $baseDir 'Tools\WingetCreateCLI'

Expand-7Zip -ArchiveFileName $winGetCreateCLISourcePath -TargetPath $winGetCreateCLIDestinationPath

Get-WinGetPackageUpdate @{
    PackageId           = 'CologneCodeCompany.XYplorerPortable'
    VersionUrl          = 'https://www.xyplorer.com/version.php'
    WinGetOwner         = $global:WingetRepositoryOwner
    WinGetRepository    = $global:WingetRepositoryName
    GitHubUsername      = $global:gitHubUsername
    AccessToken         = $accessToken
    WinGetCreateCLI     = Join-Path $winGetCreateCLIDestinationPath 'WingetCreateCLI.exe'
    SkipVersionCheck    = $skipVersionCheck.IsPresent
    SkipPRCheck         = $skipPRCheck.IsPresent
    SkipSubmit          = $skipSubmit.IsPresent
} -WhatIf:$WhatIfPreference