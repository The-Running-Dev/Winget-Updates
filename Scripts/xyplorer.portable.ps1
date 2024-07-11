[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string] $publicAccessToken,
    [Parameter()][string] $privateAccessToken,
    [Parameter()][switch] $skipVersionCheck,
    [Parameter()][switch] $skipPRCheck,
    [Parameter()][switch] $skipSubmit
)

$baseDir = Split-Path $PSScriptRoot -Parent

Import-Module (Join-Path $baseDir 'Common\Common.psm1') -Force

# Use the public token passed in as a paramater, or if empty, use the ENV token GitHubPublicAccessToken
$publicAccessToken = @{$true = $publicAccessToken; $false = $env:GitHubPublicAccessToken }["" -notmatch $publicAccessToken]

# Use the token passed in as a paramater, or if empty, use the ENV token GitHubPrivateAccessToken
$privateAccessToken = @{$true = $privateAccessToken; $false = $env:GitHubPrivateAccessToken }["" -notmatch $privateAccessToken]

$winGetCreateCLISourcePath = Join-Path $baseDir 'Tools\WinGetCreateCLI.7z'
$winGetCreateCLIDestinationDir = Join-Path $baseDir 'Tools'
$winGetCreateCLI = Join-Path $winGetCreateCLIDestinationDir 'WinGetCreateCLI\WingetCreateCLI.exe'

Install-ModuleSafe 7Zip4PowerShell
Expand-7Zip -ArchiveFileName $winGetCreateCLISourcePath -TargetPath $winGetCreateCLIDestinationDir

Get-WinGetPackageUpdate @{
    PackageId           = 'CologneCodeCompany.XYplorerPortable'
    VersionUrl          = 'https://www.xyplorer.com/version.php'
    WinGetOwner         = $global:WingetRepositoryOwner
    WinGetRepository    = $global:WingetRepositoryName
    GitHubUsername      = $global:gitHubUsername
    PublicAccessToken   = $publicAccessToken
    PrivateAccessToken  = $privateAccessToken
    WinGetCreateCLI     = $winGetCreateCLI
    SkipVersionCheck    = $skipVersionCheck.IsPresent
    SkipPRCheck         = $skipPRCheck.IsPresent
    SkipSubmit          = $skipSubmit.IsPresent
} -WhatIf:$WhatIfPreference