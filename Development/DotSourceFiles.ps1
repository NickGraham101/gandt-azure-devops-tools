##RUN WITH F5 NOT FROM PS prompt
#$VerbosePreference = "SilentlyContinue"
$VerbosePreference = "Continue"
$Classes = Get-ChildItem -Path $PSScriptRoot"\..\gandt-azure-devops-tools\Classes\*.ps1"
Write-Host "Importing $($Classes.Count) classes"

foreach($Class in $Classes) {

    try {
        Write-Verbose $Class.FullName
        . $Class.FullName

    }
    catch [System.Management.Automation.ParseException] {

        Write-Verbose "Attempting to load missing classes ..."
        $MissingClasses = (Select-String -InputObject $_.Exception.ToString() -Pattern "Unable to find type \[(\w*)\]" -AllMatches).Matches | Select-Object -ExpandProperty Value
        foreach ($MissingClass in $MissingClasses) {

            $ClassName = $MissingClass -replace '(Unable to find type \[)(.*)(\])', '$2'
            $MissingClassFile = Get-Item -Path "$($PSScriptRoot)\..\gandt-azure-devops-tools\Classes\$($ClassName).ps1"
            try {

                . $MissingClassFile.FullName
                Write-Verbose "Loaded missing class $($MissingClassFile.FullName)"
                . $Class.FullName

            }
            catch {

                Write-Warning "Failed to load class $($Class.FullName)"

            }

        }

    }
    catch {

        Write-Error "Failed to import function $($Class.FullName)"

    }

}

$Private = Get-ChildItem -Path $PSScriptRoot"\..\gandt-azure-devops-tools\Functions\Private\*.ps1"
Write-Host "Importing $($Private.Count) private functions"

foreach($Function in $Private) {

    try {

        Write-Verbose $Function.FullName
        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}

$Public = Get-ChildItem -Path $PSScriptRoot"\..\gandt-azure-devops-tools\Functions\Public\*.ps1" -Recurse
Write-Host "Importing $($Public.Count) public functions"

foreach($Function in $Public) {

    try {

        Write-Verbose $Function.FullName
        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}
