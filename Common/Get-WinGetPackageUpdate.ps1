<#
========================================================
Example Parameters
========================================================
PackageId               = 'CologneCodeCompany.XYplorer'
VersionUrl              = 'https://www.xyplorer.com/version.php'
GetInstallerUrl         = 'https://www.xyplorer.com/version.php?installer=1'
WinGetOwner             = $global:WingetRepositoryOwner
WinGetRepository        = $global:WingetRepositoryName
GitHubUsername          = $global:gitHubUsername
AccessToken             = $accessToken
#>
function Get-WinGetPackageUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable] $parameters
    )

    Exit-WithWarning `
        -Condition (-not $parameters.AccessToken) `
        -Message 'Access Token Not Set...Exiting'

    $updateParameters = @($parameters.PackageId)
    $updateParameters += '--token'
    $updateParameters += $parameters.AccessToken

    # Install needed modules
    Install-ModuleSafe Microsoft.WinGet.Client
    Install-ModuleSafe PowerShellForGitHub

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

    if ($parameters.GetInstallerUrl) {
        $installerUrl = Get-ContentFromUrl $parameters.GetInstallerUrl -WhatIf:$WhatIfPreference

        $updateParameters += '--urls'
        $updateParameters += "$($installerUrl)|x64|machine"
    }

    $updateParameters += '--version'
    $updateParameters += $latestVersion

    if (-not $parameters.SkipSubmit) {
        $updateParameters += '--submit'
    }

    # Call WinGetCreate to update the package
    Invoke-WinGetCreateUpdate `
        $updateParameters `
        -winGetCreateCLI $parameters.WinGetCreateCLI `
        -WhatIf:$WhatIfPreference
}