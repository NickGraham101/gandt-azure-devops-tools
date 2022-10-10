Push-Location -Path $PSScriptRoot\..\

Describe "Import-Module AzDevOps" -Tag "Acceptance" {

    It "Will successfully import using Import-Modules and import all classes" {

        Import-Module .\gandt-azure-devops-tools\gandt-azure-devops-tools.psm1 -Force

        # All properties for AzDevOpsProject class are base types
        & (Get-Module gandt-azure-devops-tools).NewBoundScriptBlock({[AzDevOpsProject]::new()})
        # Some properties for Release class are custom types which are loaded after the Release class
        & (Get-Module gandt-azure-devops-tools).NewBoundScriptBlock({[Release]::new()})

    }
}
