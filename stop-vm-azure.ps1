#Connect to Azure using an App Registration

$secureValue = ConvertTo-SecureString $secretValue -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationID, $secureValue

#Request a list of all VMs that required to be stopped
$vmList = @()

do {
    
    $VM = Read-Host "Please provide the list of VMs that need to be stopped separated by commas"
    $vmList += $VM

    $continue = Read-Host "Would you like to add more VMs?"

} while (
    $continue -eq "Yes"
)

#Establish connection to Azure and check if VMs 

try {
    Connect-AzAccount -Tenant $tenantID -Credential $Credential
    Write-Host "Connection to Azure Account successfull" -ForegroundColor Green
}
catch {
    Write-Host "Not able to connect to Azure Account, please verify the App registration details again...." -ForegroundColor Red
}

foreach ($item in $vmList) {
    
    $item = Get-AzVM

}
