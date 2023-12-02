function Exit-WithWarning {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [bool] $condition,
        [string] $message
    )

    if ($PSCmdlet.ShouldProcess($message, "Write-Warning")) {
        if ($condition) {
            Write-Warning $message
            exit
        }
    }
}