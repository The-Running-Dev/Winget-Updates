function Invoke-WinGetCreateUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter()][Array] $parameters,
        [Parameter()][String] $winGetCreateCLI
    )

    $cliExecutable = 'wingetcreate'

    if ($winGetCreateCLI -and (Test-Path $winGetCreateCLI -ErrorAction SilentlyContinue)) {
        $cliExecutable = $winGetCreateCLI

        Write-Warning "Using Custom WinGetCreate...$winGetCreateCLI"
    }

    if ($PSCmdlet.ShouldProcess("$($parameters.Id) --version $($parameters.Version) --urls '$($parameters.Urls)'", "wingetcreate update")) {
        & $cliExecutable update $parameters
    }
}