function Invoke-WinGetUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable] $parameters
    )

    if ($PSCmdlet.ShouldProcess("$($parameters.Id) --version $($parameters.Version) --urls '$($parameters.Urls)'", "wingetcreate update")) {
        & wingetcreate update $parameters.Id `
            --version $parameters.Version `
            --urls $parameters.Urls `
            --submit `
            --token $parameters.AccessToken
    }
}