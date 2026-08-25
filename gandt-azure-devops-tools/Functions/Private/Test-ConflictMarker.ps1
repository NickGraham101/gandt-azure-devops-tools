function Test-ConflictMarker {
<#
    .SYNOPSIS
    Checks a set of file content lines for unresolved git conflict markers.
    .DESCRIPTION
    Returns $true if any line starts with a git conflict marker (<<<<<<<, =======, >>>>>>> or |||||||).
    Used after a git-hires-merge conflict resolution attempt to confirm the tool actually resolved
    the conflict rather than leaving markers in place, which git will happily commit as plain text.
#>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        #Lines of file content to check, e.g. from Get-Content. Get-Content returns $null
        #(rather than an empty array) for a file with no lines, which AllowEmptyCollection
        #alone does not permit binding. Mandatory parameters also reject any blank-line
        #("") element in the array unless AllowEmptyString is present too - every real
        #source file has blank lines, so this fired on almost every resolved conflict.
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]$Content
    )

    return [bool]($Content | Select-String -Pattern '^(<{7}|={7}|>{7}|\|{7})')
}
