<#
Author: Rafael Bruno
Date: 08/06/2023
Note: Powershell Script to update multiple VMs sizes at the same time.
It can be adpted to do other functions as well.
#>

#Extrat information about VMs to change parameters
$csv = Import-Csv -Path ""

#Declare variables.
$securePassword = ConvertTo-SecureString $secret -AsPlainText -Force


#Connect to Azure
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $appID, $securePassword
Connect-AzAccount -ServicePrincipal -TenantId $tenantID -Credential $Credential

#Provide a list of VMs that are required to be updated.
foreach ($item in $csv) {
    $vmName = $($item.vmName)
    $resourceGroup = $($item.resourceGroup)
    $subscriptionID = $($item.subscriptionID)
    $newVMsize = $($item.newVMsize)

    Set-AzContext -Subscription $subscriptionID

    Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
    $virtualMachine = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName
    $virtualMachine.HardwareProfile.VmSize = $newVMsize
    Update-AzVM -VM $virtualMachine -ResourceGroupName $resourceGroup
    Start-AzVM -ResourceGroupName $resourceGroup -Name $vmName
}

Write-Host "All the VMs have been updated"
Break


