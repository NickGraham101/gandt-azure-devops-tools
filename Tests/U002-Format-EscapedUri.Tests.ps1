Push-Location -Path $PSScriptRoot\..\

Describe "Format-EscapedUri unit tests" -Tag "Unit" {

    $SkipPowerShellTests = $true
    $SkipPowerShellCoreTests = $true
    if ($PSVersionTable.PSVersion -lt [System.Version]::new(6,0)) {

        $SkipPowerShellTests = $false

    }
    else {

        $SkipPowerShellCoreTests = $false

    }

    . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1

    It "Will return a percent encoded uri with query string" -Skip:$SkipPowerShellTests {

        $Uri = "https://notarealinstance.visualstudio.com/notarealcollection/_apis/release/releases/1?api-version=5.0-preview.7&anotherparam=100%"
        $Output = Format-EscapedUri -Uri $Uri

        $ExpectedType = "Uri"
        $ExpectedAbsoluteUri = "https://notarealinstance.visualstudio.com/notarealcollection/_apis/release/releases/1?api-version=5.0-preview.7&anotherparam=100%25"
        $ExpectedFlags = 37615765520

        $Output.GetType().Name | Should Be $ExpectedType
        $Output.AbsoluteUri | Should Be $ExpectedAbsoluteUri
        ## See https://stackoverflow.com/a/25599183 for an explanation of this assertion
        $m_Flags = [Uri].GetField("m_Flags", $([Reflection.BindingFlags]::Instance -bor [Reflection.BindingFlags]::NonPublic))
        [uint64]$Flags = $m_Flags.GetValue($Output)
        $Flags | Should Be $ExpectedFlags
    }

    It "Will throw an exception on PowerShell Core" -Skip:$SkipPowerShellCoreTests {


        $Uri = "https://notarealinstance.visualstudio.com/notarealcollection/_apis/release/releases/1?api-version=5.0-preview.7&anotherparam=100%"
        { Format-EscapedUri -Uri $Uri } | Should -Throw "This method is not compatible with PowerShell Core"
    }
}
