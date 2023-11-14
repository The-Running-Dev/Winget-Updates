Install-Module Microsoft.WinGet.Client
Install-Module PowerShellForGitHub

# Get the current Winget version of the package
$wingetVersion = Find-WinGetPackage -Id $env:packageId | `
    Select-Object -ExpandProperty version

$release = Get-GitHubRelease `
    -OwnerName $env:owner `
    -RepositoryName $env:repository `
    -Latest
$version = $release.tag_name -replace 'v', ''

if ($version -eq $wingetVersion) {
Write-Host "Released Version ($version) == Winget Version ($wingetVersion)...Exiting"
return
}

$downloadUrl = $release.assets | `
    Where-Object name -Match 'SideQuest-Setup-.*-x64-win.exe$' | `
    Select-Object -ExpandProperty browser_download_url