Push-Location -Path $PSScriptRoot\..\

Describe "Import-Module VstsTools" -Tag "Acceptance" {

    It "Will successfully import using Import-Modules" {

        Import-Module .\VstsTools\VstsTools.psm1 -Force

    }
}