function Set-GitHubConnection {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string] $username,
        [string] $accessToken
    )
    Set-GitHubConfiguration -DisableTelemetry

    if ($PSCmdlet.ShouldProcess($username, "Set-GitHubAuthentication")) {
        $secureString = ($accessToken | ConvertTo-SecureString -AsPlainText -Force)
        $credentials = New-Object System.Management.Automation.PSCredential $username, $secureString

        Set-GitHubAuthentication -Credential $credentials
    }
}