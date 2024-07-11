$workingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptToTest = $MyInvocation.MyCommand -replace '.tests', ''

$scriptPath = Join-Path $workingDir $scriptToTest

. $scriptPath

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot 'Common\Common.psm1')
}

Describe "Test Exit Conditions" {
    Context "When Parameters are Missing" {
        BeforeEach {
            #Mock Get-Version { return 1.1 }
            #Mock Get-NextVersion { return 1.2 }
            #Mock -ModuleName Common -CommandName 'Exit-WithWarning' {} -Verifiable
        }

        It "Exits when No Token Provided" {
            Mock Exit-WithWarning {} -Verifiable
            Mock Install-ModuleSafe {} -Verifiable

            $result = Update

            $result | Should -Be $null
            Should -InvokeVerifiable
        }

        It "Calls Install-ModuleSafe" {
            Mock Exit-WithWarning {} -Verifiable
            Mock Install-ModuleSafe {} -Verifiable

            $result = Update

            $result | Should -Be $null
            Should -InvokeVerifiable
        }
    }
    <#
    Context "When there are no Changes" {
        BeforeEach {
            Mock Get-Version { return 1.1 }
            Mock Get-NextVersion { return 1.1 }
            Mock Build {}

            $result = BuildIfChanged
        }

        It "Should not build the next version" {
            Should -Invoke -CommandName Build -Times 0 -ParameterFilter { $version -eq 1.1 }
        }
    }
    #>
}