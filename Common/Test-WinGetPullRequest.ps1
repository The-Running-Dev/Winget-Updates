function Test-WinGetPullRequest {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string] $owner = $global:WingetRepositoryOwner,
        [string] $repository = $global:WingetRepositoryName,
        [string] $packageId,
        [string] $message
    )

    if ($PSCmdlet.ShouldProcess("-OwnerName '$owner' -RepositoryName '$repository' -State Open", "Get-GitHubPullRequest")) {
        $existingPullRequestUrl = Get-GitHubPullRequest `
            -OwnerName $owner `
            -RepositoryName $repository `
            -State Open | `
            Where-Object title -Match $packageId | `
            Select-Object -ExpandProperty html_url

        Exit-WithWarning `
            -Condition ($null -ne $existingPullRequestUrl) `
            -Message "Pull Request Already Exists ($existingPullRequestUrl)...Exiting"
    }
}