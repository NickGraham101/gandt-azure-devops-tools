BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
}

Describe "Invoke-AzDevOpsRestMethod unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            Collection = "notarealcollection"
            Area = "release"
            Resource = "releases"
            ResourceId = 1
            ApiVersion = "5.0-preview.7"
            ReleaseManager = $true
        }
    }


    It "If no HttpBody passed in it should call Invoke-RestMethod without the Body parameter" {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        Invoke-AzDevOpsRestMethod @SharedParams
        Should -Invoke -CommandName Invoke-RestMethod -Exactly -Times 1
        Should -Invoke -CommandName Invoke-RestMethod -Times 0 -ParameterFilter { $Body -ne $null }

    }

    It "If no HttpBody passed in it should call Invoke-RestMethod without the Body parameter" {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        $TestParams = $SharedParams
        $TestParams["HttpBody"] = @{
            definitionId = 123
            description = "Requested via API call using PAT token."
            isDraft = $false
            reason = "none"
            manualEnvironments = $null
        }

        Invoke-AzDevOpsRestMethod @SharedParams
        Should -Invoke -CommandName Invoke-RestMethod -Times 1 -ParameterFilter { $Body -ne $null }

    }

    It "If Uri passed in it should call Invoke-RestMethod with that Uri unchanged" {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        $TestUri = "https://artprodnotreal.artifacts.visualstudio.com/notarealproject/_apis/artifact/AAAA/content?format=zip"
        Invoke-AzDevOpsRestMethod -Instance "notarealinstance" -PatToken "not-a-real-token" -Uri $TestUri
        Should -Invoke -CommandName Invoke-RestMethod -Exactly -Times 1 -ParameterFilter { $Uri -eq $TestUri -and $Headers.Authorization -like "Basic *" }

    }

    It "If OutFile passed in it should call Invoke-RestMethod with the OutFile parameter" {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        Invoke-AzDevOpsRestMethod -Instance "notarealinstance" -PatToken "not-a-real-token" -Uri "https://notarealinstance.visualstudio.com/file.zip" -OutFile "TestDrive:\file.zip"
        Should -Invoke -CommandName Invoke-RestMethod -Exactly -Times 1 -ParameterFilter { $OutFile -eq "TestDrive:\file.zip" -and $Headers.Authorization -like "Basic *" }

    }

    It "If Uri is <Description> it should throw and not call Invoke-RestMethod" -ForEach @(
        @{ Description = "plain http on an Azure DevOps host"; TestUri = "http://notarealinstance.visualstudio.com/file.zip" }
        @{ Description = "https on a non Azure DevOps host"; TestUri = "https://example.com/file.zip" }
        @{ Description = "a lookalike host"; TestUri = "https://notarealinstance.visualstudio.com.example.com/file.zip" }
        @{ Description = "a file uri"; TestUri = "file:///C:/temp/file.zip" }
        @{ Description = "not absolute"; TestUri = "/notarealproject/_apis/file.zip" }
    ) {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        { Invoke-AzDevOpsRestMethod -Instance "notarealinstance" -PatToken "not-a-real-token" -Uri $TestUri } | Should -Throw "Refusing to send credentials*"
        Should -Invoke -CommandName Invoke-RestMethod -Exactly -Times 0

    }

    It "If Uri is https on <TestUri> it should call Invoke-RestMethod" -ForEach @(
        @{ TestUri = "https://dev.azure.com/notarealinstance/_apis/file.zip" }
        @{ TestUri = "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/A/content?format=zip" }
        @{ TestUri = "https://vsblobprodnotreal.vsblob.visualstudio.com/file.zip" }
    ) {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        Invoke-AzDevOpsRestMethod -Instance "notarealinstance" -PatToken "not-a-real-token" -Uri $TestUri
        Should -Invoke -CommandName Invoke-RestMethod -Exactly -Times 1

    }

}
