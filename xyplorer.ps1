$versionUrl = 'https://www.xyplorer.com/version.php'

# Install needed modules
Install-Module Microsoft.WinGet.Client -Force

# Get the current WinGet version of the package
$winGetVersion = Find-WinGetPackage -Id $packageId | `
    Select-Object -ExpandProperty version

# Get the latest version
$latestVersion = Invoke-WebRequest $versionUrl | Select-Object -ExpandProperty Content

# Latest version and WinGet version are the same...
if ($latestVersion -eq $winGetVersion) {
    Write-Host "Released Version ($latestVersion) == WinGet Version ($winGetVersion)...Exiting"
    return
}

$winGetCreate = New-Object System.Diagnostics.ProcessStartInfo;
$winGetCreate.FileName = 'wingetcreate'
$winGetCreate.UseShellExecute = $false
$winGetCreate.RedirectStandardInput = $true
$winGetCreate.Arguments = @(
    "update $packageId"
    "--version $latestVersion"
    "--urls '$downloadUrl|x64|machine|'"
    '--interactive'
    '--submit'
    "--token '${{secrets.PublicAccessToken}}'"
)

$process = [System.Diagnostics.Process]::Start($winGetCreate)

Start-Sleep -s 2

$process.StandardInput.WriteLine($RelativeFilePath)

<#
# Call WinGetCreate to update the version and URL of the package
& wingetcreate update $packageId `
    --version $latestVersion `
    --submit `
    --token ${{secrets.PublicToken} }
#>