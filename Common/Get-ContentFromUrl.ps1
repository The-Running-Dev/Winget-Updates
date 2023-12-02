function Get-ContentFromUrl {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string] $url)

    if ($PSCmdlet.ShouldProcess($url, "Invoke-WebRequest")) {
        return (Invoke-WebRequest $url | Select-Object -ExpandProperty Content)
    }
}