# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running Tests

```powershell
# Run all tests
Tests/Invoke-Tests.ps1

# Run unit tests only
Tests/Invoke-Tests.ps1 -TestType Unit

# Run with code coverage
Tests/Invoke-Tests.ps1 -CodeCoveragePath "./gandt-azure-devops-tools/**/*.ps1"

# Check results and enforce minimum 65% coverage
Tests/Out-TestResults.ps1 -CoveragePercent 65
```

Tests use Pester 5. Test files are numbered `Tests/U000-*.Tests.ps1` through `Tests/U030-*.Tests.ps1`.

## Importing the Module

```powershell
Import-Module .\gandt-azure-devops-tools\gandt-azure-devops-tools.psm1 -Force
```

For interactive development in VSCode, use `Development/DotSourceFiles.ps1` (F5) — it dot-sources all Classes, Private, and Public functions with dependency ordering.

## Architecture

The module is an Azure DevOps REST API wrapper. All public cmdlets follow the same pattern:

1. Accept `Instance` (ADO org URL), `PatToken`, and resource-specific IDs as parameters
2. Call `Invoke-AzDevOpsRestMethod` (the sole private API wrapper) with endpoint + API version
3. Deserialize JSON into a custom class object via a companion `New-<ClassName>Object` helper
4. Return the typed object

**`Functions/Private/Invoke-AzDevOpsRestMethod.ps1`** is the core — handles authentication, URI construction, and HTTP verb dispatch for all API calls.

**`Classes/`** contains 20 property-only data classes (no methods) that map ADO API responses to typed PowerShell objects.

**`Functions/Public/`** is organized by ADO resource area: `Build/`, `Core/`, `Git/`, `Pipeline/`, `PullRequest/`, `Release/`, `Test/`, and `Combined/`. The `Combined/` subfolder holds higher-level orchestration functions (`Merge-MultiplePullRequest`, `New-SerialDeployment`, etc.) that compose multiple public functions.

The `.psm1` loader handles class dependency resolution automatically — if a class references a type not yet loaded, it defers and retries after all other classes load.

## Adding New Functions

Match the existing pattern:
- One file per function in the appropriate `Functions/Public/<Area>/` subfolder
- A corresponding numbered test file in `Tests/`
- If a new ADO resource type is needed, add a class in `Classes/` and a `New-<ClassName>Object` helper at the bottom of the function file
- The module auto-exports all files under `Functions/Public/` — no manifest updates needed
