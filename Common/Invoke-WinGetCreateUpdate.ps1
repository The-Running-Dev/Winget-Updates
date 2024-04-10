function Invoke-WinGetCreateUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter()][Array] $parameters,
        [Parameter()][bool] $skipSubmit
    )

    if ($skipSubmit) {
        $parameters | Format-Table

        Write-Output "& wingetcreate update $parameters"
    }
    else {
        if ($PSCmdlet.ShouldProcess("$($parameters.Id) --version $($parameters.Version) --urls '$($parameters.Urls)'", "wingetcreate update")) {
            & wingetcreate update $parameters
        }
    }
}