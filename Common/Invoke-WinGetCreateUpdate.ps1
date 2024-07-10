function Invoke-WinGetCreateUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter()][Array] $parameters,
        [Parameter()][String] $winGetCreateCLI,
        [Parameter()][Bool] $skipSubmit
    )

    $parameters | Format-Table

    $cliExecutable = 'wingetcreate'

    if ($winGetCreateCLI -and (Test-Path $winGetCreateCLI -ErrorAction SilentlyContinue)) {
        $cliExecutable = $winGetCreateCLI

        Write-Warning "Using Custom WinGetCreate...$winGetCreateCLI"
    }

    if ($skipSubmit) {
        $parameters | Format-Table

        Write-Output "& wingetcreate update $parameters"
    }
    else {
        if ($PSCmdlet.ShouldProcess("$($parameters.Id) --version $($parameters.Version) --urls '$($parameters.Urls)'", "wingetcreate update")) {
            & $cliExecutable update $parameters
        }
    }
}