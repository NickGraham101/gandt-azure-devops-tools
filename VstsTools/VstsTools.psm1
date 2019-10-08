$script:ModuleGitHubRepo = "https://github.com/NickGraham101/VstsTools/issues"

$Classes = Get-ChildItem -Path "$($PSScriptRoot)\Classes\*.ps1" -Verbose:$VerbosePreference

foreach($Class in $Classes) {

    try {

        . $Class.FullName

    }
    catch [System.Management.Automation.ParseException] {

        $MissingClasses = (Select-String -InputObject $_.Exception.ToString() -Pattern "Unable to find type \[(\w*)\]" -AllMatches).Matches | Select-Object -ExpandProperty Value
        foreach ($MissingClass in $MissingClasses) {

            $ClassName = $MissingClass -replace '(Unable to find type \[)(.*)(\])', '$2'
            $MissingClassFile = Get-Item -Path "$($PSScriptRoot)\Classes\$($ClassName).ps1"
            try {
    
                . $MissingClassFile.FullName
                . $Class.FullName
        
            }
            catch {
    
                Write-Warning "Failed to load class $($Class.FullName)"
    
            }

        }

    }
    catch {

        throw "Failed to import function $($Class.FullName)"

    }

}

$Private = Get-ChildItem -Path "$($PSScriptRoot)\Functions\Private\*.ps1" -Verbose:$VerbosePreference

foreach($Function in $Private) {

    try {

        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}

$Public = Get-ChildItem -Path "$($PSScriptRoot)\Functions\Public\*.ps1" -Recurse -Verbose:$VerbosePreference

foreach($Function in $Public) {

    try {

        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}

Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName) -Verbose:$VerbosePreference