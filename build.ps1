$owner = 'SideQuestVR'
$repository = 'EasyInstallerReleases'
$packageId = 'SideQuestVR.SideQuestEasyInstaller'
$wingetCreateUrl = 'https://aka.ms/wingetcreate/latest'

Install-Module Microsoft.WinGet.Client
Install-Module PowerShellForGitHub

# Get the current Winget version of the package
$wingetVersion = Find-WinGetPackage -Id $packageId | `
    Select-Object -ExpandProperty version

$release = Get-GitHubRelease `
    -OwnerName $owner `
    -RepositoryName $repository `
    -Latest
$version = $release.tag_name -replace 'v', ''

if ($version -eq $wingetVersion) {
Write-Host "Released Version ($version) == Winget Version ($wingetVersion)...Exiting"
return
}

$downloadUrl = $release.assets | `
    Where-Object name -Match 'SideQuest-Setup-.*-x64-win.exe$' | `
    Select-Object -ExpandProperty browser_download_url

Invoke-WebRequest $wingetCreateUrl -OutFile wingetcreate.exe

.\wingetcreate.exe update $packageId `
--urls '$downloadUrl' '$downloadUrl' `
--version $version `
#--submit `
#--token ${{secrets.PublicToken}}