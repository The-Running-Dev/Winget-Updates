[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string] $accessToken,
    [Parameter()][switch] $skipVersionCheck,
    [Parameter()][switch] $skipPRCheck,
    [Parameter()][switch] $skipSubmit
)

$baseDir = Split-Path $PSScriptRoot -Parent

Import-Module (Join-Path $baseDir 'Common\Common.psm1') -Force

# Use the public token passed in as a paramater, or if empty, use the ENV token GitHubAccessToken
$accessToken = @{$true = $accessToken; $false = $env:GitHubAccessToken }["" -notmatch $accessToken]

$winGetCreateCLISourcePath = Join-Path $baseDir 'Tools\WinGetCreateCLI.7z'
$winGetCreateCLIDestinationDir = Join-Path $baseDir 'Tools'
$winGetCreateCLI = Join-Path $winGetCreateCLIDestinationDir 'WinGetCreateCLI\WingetCreateCLI.exe'

Install-ModuleSafe 7Zip4PowerShell
Expand-7Zip -ArchiveFileName $winGetCreateCLISourcePath -TargetPath $winGetCreateCLIDestinationDir

Get-WinGetPackageUpdate @{
    PackageId               = 'CologneCodeCompany.XYplorerPortable'
    VersionUrl              = 'https://www.xyplorer.com/version.php'
    WinGetOwner             = $global:WingetRepositoryOwner
    WinGetRepository        = $global:WingetRepositoryName
    GitHubUsername          = $global:gitHubUsername
    AccessToken             = $accessToken
    WinGetCreateCLI         = $winGetCreateCLI
    SkipVersionCheck        = $skipVersionCheck.IsPresent
    SkipPRCheck             = $skipPRCheck.IsPresent
    SkipSubmit              = $skipSubmit.IsPresent
} -WhatIf:$WhatIfPreference