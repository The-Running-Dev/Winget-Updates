<#
========================================================
Example Parameters
========================================================
PackageId           = 'CologneCodeCompany.XYplorer'
VersionUrl          = 'https://www.xyplorer.com/version.php'
GetInstallerUrl     = 'https://www.xyplorer.com/version.php?installer=1'
WinGetOwner         = $global:WingetRepositoryOwner
WinGetRepository    = $global:WingetRepositoryName
GitHubUsername      = $global:gitHubUsername
PublicAccessToken   = $publicAccessToken
PrivateAccessToken  = $privateAccessToken
#>
function Get-WinGetPackageUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable] $parameters
    )

    $updateParameters = @($parameters.PackageId)
    $updateParameters += '--token'
    $updateParameters += $parameters.PrivateAccessToken

    Exit-WithWarning `
        -Condition (-not $parameters.PublicAccessToken) `
        -Message 'Public Access Token Not Set...Exiting'

    Exit-WithWarning `
        -Condition (-not $parameters.PrivateAccessToken) `
        -Message 'Private Access Token Not Set...Exiting'

    # Install needed modules
    Install-ModuleSafe Microsoft.WinGet.Client
    Install-ModuleSafe PowerShellForGitHub

    # Setup GitHub connection with the PAT token
    Set-GitHubConnection $parameters.GitHubUsername $parameters.PrivateAccessToken -WhatIf:$WhatIfPreference

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
        -skipSubmit $parameters.SkipSubmit `
        -WhatIf:$WhatIfPreference
}