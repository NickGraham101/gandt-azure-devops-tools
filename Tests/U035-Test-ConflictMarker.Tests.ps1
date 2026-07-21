BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Test-ConflictMarker.ps1
}

Describe "Test-ConflictMarker unit tests" -Tag "Unit" {

    It "Will return false for content with no conflict markers" {

        $Content = @("using System;", "namespace Foo {", "}")
        Test-ConflictMarker -Content $Content | Should -Be $false
    }

    It "Will return true when content contains a conflict start marker" {

        $Content = @("using System;", "<<<<<<< HEAD", "namespace Foo {", "}")
        Test-ConflictMarker -Content $Content | Should -Be $true
    }

    It "Will return true when content contains a conflict separator marker" {

        $Content = @("using System;", "=======", "namespace Foo {", "}")
        Test-ConflictMarker -Content $Content | Should -Be $true
    }

    It "Will return true when content contains a conflict end marker" {

        $Content = @("using System;", ">>>>>>> feature-branch", "namespace Foo {", "}")
        Test-ConflictMarker -Content $Content | Should -Be $true
    }

    It "Will return true when content contains a diff3 common-ancestor marker" {

        $Content = @("using System;", "||||||| merged common ancestors", "namespace Foo {", "}")
        Test-ConflictMarker -Content $Content | Should -Be $true
    }

    It "Will return false for an empty content array" {

        Test-ConflictMarker -Content @() | Should -Be $false
    }
}
