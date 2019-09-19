[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$ContainerImageName,
    [Parameter(Mandatory=$true)]
    [String]$ContainerName,
    [Parameter(Mandatory=$true)]
    [String]$ResourceGroupName
)

$ContainerGroup = Get-AzContainerGroup -ResourceGroupName $ResourceGroupName -Name $ContainerName
Write-Verbose "Container Group with Name $($ContainerGroup.Name) retrieved"

if ($ContainerGroup.Containers[0].Image -eq $ContainerImageName) { 
    
    Write-Verbose "Setting ImageNeedsUpdating to 'true'"
    Write-Output "##vso[task.setvariable variable=ImageNeedsUpdating]true" 

}

if ($ContainerGroup.State -ne "Running") { 
    
    Write-Verbose "Setting ContainerNeedsStarting to 'true'"
    Write-Output "##vso[task.setvariable variable=ContainerNeedsStarting]true" 

}