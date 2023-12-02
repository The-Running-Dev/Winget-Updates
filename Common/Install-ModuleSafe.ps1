function Install-ModuleSafe {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string] $moduleName)

    if ($PSCmdlet.ShouldProcess($moduleName, "Get-Module")) {
        if (-not (Get-Module -Name $moduleName )) {
            Install-Module $moduleName -Force
        }
    }
}