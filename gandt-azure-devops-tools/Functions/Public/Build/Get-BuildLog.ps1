<#
    .NOTES
    API Reference List: https://learn.microsoft.com/en-us/rest/api/azure/devops/build/builds/get-build-logs?view=azure-devops-rest-7.1
    API Reference Get: https://learn.microsoft.com/en-us/rest/api/azure/devops/build/builds/get-build-log?view=azure-devops-rest-7.1
#>
function Get-BuildLog {
    [CmdletBinding(DefaultParameterSetName="List")]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [int]$BuildId,

        #The id of an individual log, returns the log content as a string
        [Parameter(Mandatory=$true, ParameterSetName="Content")]
        [int]$LogId,

        #The first line of the log to return, defaults to the start of the log
        [Parameter(Mandatory=$false, ParameterSetName="Content")]
        [int]$StartLine,

        #The last line of the log to return, defaults to the end of the log
        [Parameter(Mandatory=$false, ParameterSetName="Content")]
        [int]$EndLine
    )

    process {

        $GetBuildLogParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "build"
            Resource = "builds"
            ResourceId = $BuildId
            ResourceComponent = "logs"
            ApiVersion = "7.1"
        }

        if ($PSCmdlet.ParameterSetName -eq "Content") {

            $GetBuildLogParams["ResourceComponentId"] = $LogId

            $AdditionalUriParameters = @{}
            if ($PSBoundParameters.ContainsKey("StartLine")) {

                $AdditionalUriParameters["startLine"] = $StartLine

            }
            if ($PSBoundParameters.ContainsKey("EndLine")) {

                $AdditionalUriParameters["endLine"] = $EndLine

            }
            if ($AdditionalUriParameters.Count -gt 0) {

                $GetBuildLogParams["AdditionalUriParameters"] = $AdditionalUriParameters

            }

            $LogContent = Invoke-AzDevOpsRestMethod @GetBuildLogParams

            return $LogContent

        }

        $LogsJson = Invoke-AzDevOpsRestMethod @GetBuildLogParams

        $BuildLogs = foreach ($Log in $LogsJson.value) {

            $BuildLog = New-Object -TypeName BuildLog
            $BuildLog.BuildId = $BuildId
            $BuildLog.LogId = $Log.id
            $BuildLog.Type = $Log.type
            $BuildLog.CreatedOn = $Log.createdOn
            $BuildLog.LastChangedOn = $Log.lastChangedOn
            $BuildLog.LineCount = $Log.lineCount
            $BuildLog.Url = $Log.url
            $BuildLog

        }

        $BuildLogs

    }

}
