function Invoke-WinGetCreateUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter()][Array] $parameters,
        [Parameter()][String] $winGetCreateCLI,
        [Parameter()][Bool] $skipSubmit
    )

    $cliExecutable = 'wingetcreate'

    Write-Warning $winGetCreateCLI
    Write-Warning "$(Test-Path $winGetCreateCLI)"

    if ($winGetCreateCLI -and (Test-Path $winGetCreateCLI -ErrorAction SilentlyContinue)) {
        $cliExecutable = $winGetCreateCLI
    }

    if ($skipSubmit) {
        $parameters | Format-Table

        Write-Output "& wingetcreate update $parameters"
    }
    else {
        if ($PSCmdlet.ShouldProcess("$($parameters.Id) --version $($parameters.Version) --urls '$($parameters.Urls)'", "wingetcreate update")) {
            "& $cliExecutable update $parameters"
        }
    }
}