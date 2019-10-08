Push-Location -Path $PSScriptRoot\..\

Describe "Import-Module VstsTools" -Tag "Acceptance" {

    It "Will successfully import using Import-Modules and import all classes" {

        Import-Module .\VstsTools\VstsTools.psm1 -Force

        # All properties for VstsProject class are base types
        & (Get-Module VstsTools).NewBoundScriptBlock({[VstsProject]::new()})
        # Some properties for Release class are custom types which are loaded after the Release class
        & (Get-Module VstsTools).NewBoundScriptBlock({[Release]::new()})

    }
}