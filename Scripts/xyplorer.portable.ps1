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

# Replace the WingetCreateCore file with the local patched one
$winGetCreateCoreDll = 'WingetCreateCore.dll'
$winGetCreateCoreDllSourcePath = Join-Path $baseDir "Tools\$winGetCreateCoreDll"

$winGetCreateDir = Get-ChildItem 'C:\Program Files\WindowsApps' -Recurse 'WingetCreateCore.dll' | `
    Sort-Object -Descending | `
    Select-Object -First 1 -ExpandProperty Directory | `
    Select-Object -ExpandProperty FullName

if (Test-Path $winGetCreateDir) {
    $winGetCreateCoreDllDestinationPath = Join-Path $winGetCreateDir $winGetCreateCoreDll
    
    Copy-ProtectedFile $winGetCreateCoreDllSourcePath $winGetCreateCoreDllDestinationPath
}

Get-WinGetPackageUpdate @{
    PackageId           = 'CologneCodeCompany.XYplorerPortable'
    VersionUrl          = 'https://www.xyplorer.com/version.php'
    WinGetOwner         = $global:WingetRepositoryOwner
    WinGetRepository    = $global:WingetRepositoryName
    GitHubUsername      = $global:gitHubUsername
    AccessToken         = $accessToken
    SkipVersionCheck    = $skipVersionCheck.IsPresent
    SkipPRCheck         = $skipPRCheck.IsPresent
    SkipSubmit          = $skipSubmit.IsPresent
} -WhatIf:$WhatIfPreference