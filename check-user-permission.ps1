#Variables
. .\variables.ps1

#Retrive Servers

Invoke-Command -ComputerName "server-name" -ScriptBlock{

    $computerName = Get-ADComputer -Filter * -Properties Name | Where-Object {$_.Name -like "#*" -and $_.Name -notlike "*####*"}

    #Create folder
    if (Test-Path C:\Testing) {
        Write-Host "Folder Testing already exists!" -ForegroundColor Green
    }
    else {
        Write-Host "Folder doesn't exist - Creating a new folder...." -ForegroundColor Red
        New-Item -ItemType Directory -Path 'C:\' -Name 'Testing'
        Write-Host "### Folder Created ###" -ForegroundColor Green
    }


    $Premises | Out-File -FilePath 

}

#Check if server is operational by test ping again it
$TestConnection = Test-Connection -ComputerName $Premises -Count 1 -Quiet | Select Address

if ($TestConnection) {
    
}
else {
    Write-Host "Not able to contact the servers" -ForegroundColor Red -BackgroundColor Black
}

#Get Users and Groups in Remote Dekstop Users and Admin



#Compare users against the group to see if the users is present inside


#Remove User if user is not on the group