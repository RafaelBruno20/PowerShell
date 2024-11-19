#variables

#Check if MS Graph is installed
$MSGprah = Get-Module | Where-Object {$_.Name -match "Microsoft.Graph"}
if ($MSGprah) {
    Write-Output "Module Microsoft Graph is installed." -ForegroundColor Green 
}
else {
    Write-Output "Module Microsoft Graph is not installed." -ForegroundColor Red
    Write-Warning "Installing Module now..."
    Install-Module -Name Microsoft.Graph
}

#Connect to Azure

#Convert secret value to a secure string.
$securePassword = ConvertTo-SecureString $secretValue -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientID, $securePassword

#Get all the users that are listed as Guest
$GuestUsers = Get-MgUser -Filter "userType eq 'Guest'"
#Get all the users that are not listed as Quest
$NonGuestUsers = Get-MgUser -Filter "userType eq 'Member'"

#Check if guest users have duplicates
foreach ($user in $GuestUsers) {
    if ($user.DisplayName -contains $NonGuestUsers.DisplayName) {
        
        Write-Host "$($user.DisplayName) has a duplicated account." -ForegroundColor Red
        Write-Host "Disabling the guest account now...." -ForegroundColor Yellow

        Update-MgUser -UserId $user.Id -AccountEnabled $false

        Write-Host "User $($user.DisplayName) has been disabled!" -ForegroundColor Green
    }
    else {
        
        Write-Host "User $($user.DisplayName) has not been found. Please confirm the name is correct!" -ForegroundColor Red

    }
}

Write-Host "All duplicated users have been disabled!" -ForegroundColor Green