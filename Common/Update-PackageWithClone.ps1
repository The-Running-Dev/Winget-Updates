<#
========================================================
Example Parameters
========================================================
PackageId           = 'CologneCodeCompany.XYplorer'
VersionUrl          = 'https://www.xyplorer.com/version.php'
WinGetRepository    = $global:WingetRepositoryName
WinGetOwner         = $global:WingetRepositoryOwner
RepositoryUrl       = 'https://'
GitHubUsername      = $global:gitHubUsername
AaccessToken        = $accessToken
#>
function Update-WithYamlCreate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable] $parameters
    )

    Exit-WithWarning `
        -Condition (-not $parameters.AccessToken) `
        -Message 'GitHub Access Token Not Set...Exiting'

    Exit-WithWarning `
        -Condition (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) `
        -Message 'Git Not Installed...Exiting'

    # Install needed modules
    Install-ModuleSafe Microsoft.WinGet.Client
    Install-ModuleSafe PowerShellForGitHub
    Install-ModuleSafe powershell-yaml
    Import-Module Appx -UseWinPS -SkipEditionCheck

    # Setup GitHub connection with the PAT token
    Set-GitHubConnection $parameters.GitHubUsername $parameters.AccessToken -WhatIf:$WhatIfPreference

    # Get the current WinGet version of the package
    $winGetVersion = Get-WinGetVersion $parameters.PackageId -WhatIf:$WhatIfPreference

    # Get the latest version
    $latestVersion = Get-ContentFromUrl $parameters.VersionUrl -WhatIf:$WhatIfPreference

    if (-not $parameters.SkipVersionCheck) {
        # Latest version and WinGet version are the same...
        Exit-WithWarning `
            -Condition ($latestVersion -eq $winGetVersion) `
            -Message "Latest Version ($latestVersion) == WinGet Version ($winGetVersion)...Exiting"
    }

    if (-not $parameters.SkipPRCheck) {
        # Check for existing pull request for this package
        Test-WinGetPullRequest -packageId $parameters.PackageId -owner $parameters.WinGetOwner -WhatIf:$WhatIfPreference
    }

    if ($PSCmdlet.ShouldProcess($parameters.YamlCreateRepositoryUrl, 'git clone')) {
        if (-not $parameters.SkipClone) {
            if (Test-Path $parameters.YamlCreateRepositoryDir) {
                Write-Warning "$($parameters.YamlCreateRepositoryDir) Exists...Deleting"

                Remove-Item -Recurse -Force $parameters.YamlCreateRepositoryDir
            }

            & git clone $parameters.YamlCreateRepositoryUrl $parameters.YamlCreateRepositoryDir
        }
    }

    $yamlCreateScript = "$($parameters.YamlCreateRepositoryDir)\Tools\YamlCreate.ps1"
    $yamlCreateParams = "-Mode 2 -AutoUpgrade -PackageIdentifier $($parameters.PackageId) -PackageVersion $latestVersion"

    if ($PSCmdlet.ShouldProcess($yamlCreateScript, $yamlCreateParams)) {
        if (Test-Path $parameters.YamlCreateRepositoryDir) {
            if (-not $parameters.SkipSubmit) {
                $settingsSource = Join-Path $(Split-Path $parameters.YamlCreateRepositoryDir -Parent) 'YamlCreate.yml'
                $settingsDestinationDir = "$($env:LocalAppData)\YamlCreate"

                New-Item -ItemType Directory $settingsDestinationDir -Force | Out-Null

                $settingsDestination = Join-Path $settingsDestinationDir 'Settings.yaml'
                Copy-Item $settingsSource $settingsDestination -Force

                # Call YamlCreate to update the package
                & $yamlCreateScript `
                    -Mode 2 `
                    -AutoUpgrade `
                    -PackageIdentifier $parameters.PackageId `
                    -PackageVersion $latestVersion
            }
            else {
                Write-Output "$yamlCreateScript $updateParameters"
            }
        }
    }
}