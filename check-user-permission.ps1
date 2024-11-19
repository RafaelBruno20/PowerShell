#Variables
. .\variables.ps1

#Retrive Servers
function RetriveListServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("APP", "WEB", "REP", "SQL")]
        [string]
        $ServerType,

        [Parameter(Mandatory=$true)]
        [ValidateSet("DEV", "UAT", "PREPRO", "PROD")]
        [string]
        $environmentType
    )

    try {

        #Get all computer 
        $computer = Get-ADComputer -Filter {Name}


    }
    catch {
        $message = $_
        Write-Host "ERROR: $message" -ForegroundColor Red
    }
    
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