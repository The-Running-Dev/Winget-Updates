function Copy-ProtectedFile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string] $sourceFile,
        [string] $destinationFile
    )

    if ($PSCmdlet.ShouldProcess($destinationFile, "Copy-ProtectedFile")) {
        $newAcl = Get-Acl -Path $destinationFile

        # Set properties
        $identity = "BUILTIN\Administrators"
        $fileSystemRights = "FullControl"
        $type = "Allow"

        # Create new rule
        $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
        $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList

        # Apply new rule
        $newAcl.SetAccessRule($fileSystemAccessRule)
        Set-Acl -Path $destinationFile -AclObject $newAcl

        Copy-Item $sourceFile $destinationFile -Force
    }
}