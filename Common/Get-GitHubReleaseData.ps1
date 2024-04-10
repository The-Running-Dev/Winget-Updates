function Get-GitHubReleaseData {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string] $owner,
        [string] $repository,
        [string] $installerRegEx
    )

    if ($PSCmdlet.ShouldProcess("-OwnerName $owner -RepositoryName $repository -Latest", "Get-GitHubRelease")) {
        $release = Get-GitHubRelease `
            -OwnerName $owner `
            -RepositoryName $repository `
            -Latest

        # Get the latest version from the tag_name
        $version = $release.tag_name -replace 'v', ''

        # Get the installer URL
        $url = $release.assets | `
            Where-Object name -Match $installerRegEx | `
            Select-Object -ExpandProperty browser_download_url

        return @{
            Version = $version
            Url     = $url
        }
    }
}