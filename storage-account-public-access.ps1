#App Registration Acces
#Calling file with variable files. Gets ignored by Git
. .\variables.ps1

#Define Error Preference
$ErrorActionPreference = 'Stop'
$logFile = 'C:\GitClone\Test\error-log.txt'

#Convert secret value to a secure string.
$securePassword = ConvertTo-SecureString $secretValue -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $clientID, $securePassword

try {

    #Connect to Azure
    Connect-AzAccount -ServicePrincipal -Tenant $tenantID -Credential $credential -ErrorVariable "ErrorLog" -Verbose
    $ErrorLog | Out-File -FilePath $logFile -Append

    #Set Context
    Set-AzContext -Subscription $subscriptionID

    #Retrive all storage account
    #UK South is where most of the storage account are located. Focus first on those
    $storageAccountList = Get-AzStorageAccount | Where-Object {$_.Location -eq "uksouth"} -Verbose

    #Check if storage account allow public access and if private endpoints are in place
    foreach ($item in $storageAccountList) {
        #Retrive the network settings for storage accounts
        $networkRuleSet = Get-AzStorageAccount -ResourceGroupName $item.ResourceGroupName -Name $item.StorageAccountName

        if ($networkRuleSet.PublicNetworkAccess -eq 'Enabled') {
            Write-Host "Storage Account $($item.StorageAccountName) is allowing Public Access." -BackgroundColor Yellow -ForegroundColor Red
            #Check if private endpoint is in place
            $privateConnection = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $item.Id

            if ($privateConnection) {
                #Public Access allowed and Private Endpoint is in place = Disable Public Access
                Write-Host "PE connection is enabled for storage account $($item.StorageAccountName)." -ForegroundColor Yellow

                Write-Host "#Disabling Public Access#" -ForegroundColor Green
                Set-AzStorageAccount -ResourceGroupName $item.ResourceGroupName -Name $item.StorageAccountName -PublicNetworkAccess Disabled
            }
            else {
                #Public Access allowed and Private Endpoint is not in place = Create Private Endpoint
                Write-Host "PE connection is disabled for storage account $($item.StorageAccountName)."
                Write-Host "#Creating a private endpoint#"

                #Get ResourceID for the storage account
                $resourceID = $item.Id

                #Virtual Network to host the private endpoint
                $vnet = Get-AzVirtualNetwork -Name "" -ResourceGroupName ""
                $subnetID = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "Default"

                $pec = @{
                    Name = "$($item.StorageAccountName)-pec"
                    PrivateLinkServiceID = $resourceID
                    GroupID = "blob"
                }

                $privateEndpointConnection = New-AzPrivateLinkServiceConnection @pec -Verbose

                $pe = @{
                    ResourceGroupName = $vnet.ResourceGroupName
                    Name = "$($item.StorageAccountName)-pe"
                    Location = $defaultLocation
                    Subnet = $subnetID
                    PrivateLinkServiceConnection = $privateEndpointConnection
                }

                New-AzPrivateEndpoint @pe -Verbose
                #Wait for private endpoint to create
                Start-Sleep -Seconds 60
                $privateEndpoint = Get-AzPrivateEndpoint @pe -Verbose
                Write-Host "New Private Endpoint: $($privateEndpoint.Name) has been created on connection storage account name: $($item.StorageAccountName)." -ForegroundColor Green
                

            }                
        }
        elseif ($networkRuleSet.PublicNetworkAccess -eq 'Disabled') {
            #Public Access not allowed
            Write-Host "Storage Account $($item.StorageAccountName) is blocking Public Access." -ForegroundColor Green
            #Check if private endpoint is in place
            $privateConnection = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $item.Id

            if ($privateConnection) {
                #Public Access disabled and Private Endpoint is in place = Not Changes Required
                Write-Host "No changes required for storage account $($item.StorageAccountName)." -ForegroundColor Green
            }
            else {
                #Public Access disabled and Private Endpoint is not in place = Create Private Endpoint
                Write-Host "PE connection is disabled for storage account $($item.StorageAccountName)."
                Write-Host "#Creating a private endpoint#"

                #Get ResourceID for the storage account
                $resourceID = $item.Id

                #Virtual Network to host the private endpoint
                $vnet = Get-AzVirtualNetwork -Name "powershell-test-vnet01" -ResourceGroupName "powershell-test-resource-group"
                $subnetID = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "Default"

                $pec = @{
                    Name = "$($item.StorageAccountName)-pec"
                    PrivateLinkServiceID = $resourceID
                    #Group ID refers to the type of private link (blob, file, table, etc...)
                    GroupID = "blob"
                }

                $privateEndpointConnection = New-AzPrivateLinkServiceConnection @pec -Verbose

                $pe = @{
                    ResourceGroupName = $vnet.ResourceGroupName
                    Name = "$($item.StorageAccountName)-pe"
                    Location = $defaultLocation
                    Subnet = $subnetID
                    PrivateLinkServiceConnection = $privateEndpointConnection
                }

                New-AzPrivateEndpoint @pe -Verbose
                #Wait for private endpoint to create
                Start-Sleep -Seconds 60
                $privateEndpoint = Get-AzPrivateEndpoint @pe -Verbose
                $privateEndpointIP = $privateEndpoint.NetworkInterfaces

                Write-Host "New Private Endpoint: $($privateEndpoint.Name) `
                has been created on connection storage account name: $($item.StorageAccountName)." -ForegroundColor Green
            
            }

        }

        #Build private DNS zone name based on Group ID
        $DNSName = "privatelink.$($blobType).core.windows.net"
        $vnetName = ""

        #Get all DNS zone that match the blob type (GroupID)
        $privateDNSZone = Get-AzPrivateDnsZone | Where-Object {$_.Name -match "$($blobType)"}

        foreach ($zone in $privateDNSZone) {
            #Filter to find the on connected to VNUK01.
            $networkLink = Get-AzPrivateDnsVirtualNetworkLink `
            -ResourceGroupName $zone.ResourceGroupName `
            -ZoneName $zone.Name

            #If private DNS zone exists, add record. If private DNS zone doesn't exist, create a PDNSZ and add the record.
            if ($networkLink.VirtualNetworkId -match $vnetName) {
                Write-Output "The private DNS zone $($zone.Name) is linked to $($vnetName)" -ForegroundColor Green
                Write-Output "Writing a new DNS record"

                New-AzPrivateDnsRecordSet -Name -RecordType A `
                -ZoneName $zone.Name `
                -ResourceGroupName 
            }
            else {
                Write-Output "The private DNS zone $($zone.Name) is not linked to $($vnetName)" -ForegroundColor Red
                break
            }
        }
    }
}
catch {
    Write-Error $_.Exception.Message | Out-File -FilePath $logFile -Append
    Write-Host "Not able to connect to the Azure Tenant!" -ForegroundColor Red
    break
}

