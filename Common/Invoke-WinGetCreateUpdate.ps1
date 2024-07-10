function Invoke-WinGetCreateUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter()][Array] $parameters,
        [Parameter()][String] $wingetCreateCLI,
        [Parameter()][Bool] $skipSubmit
    )

    $cliExecutable = 'wingetcreate'

    if ($wingetCreateCLI -and (Test-Path $wingetCreateCLI -ErrorAction SilentlyContinue)) {
        $cliExecutable = $wingetCreateCLI
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