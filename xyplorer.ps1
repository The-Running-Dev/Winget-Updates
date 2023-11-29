$versionUrl = 'https://www.xyplorer.com/version.php'
$packageId = 'CologneCodeCompany.XYplorer'
$versionUrl = 'https://www.xyplorer.com/version.php'
$downloadUrl = 'https://www.xyplorer.com/download/xyplorer_full.zip'

# Install needed modules
Install-Module Microsoft.WinGet.Client -Force

# Get the current WinGet version of the package
$winGetVersion = Find-WinGetPackage -Id $packageId -MatchOption Equals | `
    Select-Object -ExpandProperty version

# Get the latest version
$latestVersion = Invoke-WebRequest $versionUrl | Select-Object -ExpandProperty Content

# WinGet version does not exist...
if (-not $winGetVersion) {
    Write-Warning "Package Does Not Exist on WinGet...Exiting"
    return
}

# Latest version and WinGet version are the same...
if ($latestVersion -eq $winGetVersion) {
    Write-Warning "Latest Version ($latestVersion) == WinGet Version ($winGetVersion)...Exiting"
    return
}

$zipFile = Join-Path . (Split-Path -Leaf $downloadUrl)
Invoke-WebRequest $downloadUrl -out $zipFile

[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
$RelativeFilePath = [IO.Compression.ZipFile]::OpenRead($zipFile).Entries | `
    Where-Object Name -Match '.exe' | `
    Select-Object -ExpandProperty Name

$winGetCreate = New-Object System.Diagnostics.ProcessStartInfo;
$winGetCreate.FileName = 'wingetcreate'
$winGetCreate.UseShellExecute = $false
$winGetCreate.RedirectStandardInput = $true
$winGetCreate.Arguments = @(
    "update $packageId"
    "--version $latestVersion"
    "--urls '$downloadUrl|x64|machine'"
    "--interactive"
    "--submit"
    "--token $env:PublicAccessToken"
)

Write-Debug ($winGetCreate.Arguments | ConvertTo-Json)

$process = [System.Diagnostics.Process]::Start($winGetCreate)

Start-Sleep -s 10

$process.StandardInput.WriteLine($RelativeFilePath)

# Call WinGetCreate to update the version and URL of the package
<#
          & wingetcreate update $packageId `
            --version $latestVersion `
            --urls "$downloadUrl|x64|machine|$RelativeFilePath" `
            --interactive `
            --submit `
            --token $env:PublicAccessToken'
          #>