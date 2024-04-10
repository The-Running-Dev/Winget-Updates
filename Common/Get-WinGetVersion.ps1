function Get-WinGetVersion {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string] $packageId)

    if ($PSCmdlet.ShouldProcess("-Id $packageId", "Find-WinGetPackage")) {
        $winGetVersion = Find-WinGetPackage -Id $packageId -MatchOption Equals | `
            Select-Object -ExpandProperty version
    }

    # WinGet version does not exist...
    Exit-WithWarning `
        -Condition (-not $winGetVersion) `
        -Message 'Package Does Not Exist on WinGet...Exiting'

    return $winGetVersion
}