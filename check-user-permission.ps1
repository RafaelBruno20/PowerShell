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
        $computerList = Get-ADComputer -Filter * | Where-Object {$_.Name -match $ServerType} | Where-Object {$_.Name -match $environmentType}
        $computerList | Select-Object Name
        return $computerList

    }
    catch {
        $message = $_
        Write-Host "ERROR: $message" -ForegroundColor Red
        Write-Host "Not able to retrive the system request!" -ForegroundColor Red
    }
    
}

#Check if server is operational by test ping again it
function CheckConnection {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $computerList
    )
    $pingableComputers = @()
    foreach ($computer in $computerList) {

        $TestConnection = Test-Connection -ComputerName $computer.Name -Count 5 -Quiet | Select-Object Address

        if ($TestConnection) {
            Write-Host "###$($computer.DisplayName)###$($TestConnection)###Success###" -ForegroundColor DarkGreen
            $pingableComputers += $computer
        }
        else {
            Write-Host "Not able to contact $($computer.DisplayName)" -ForegroundColor Red -BackgroundColor Red
        }
        
    }
    return $pingableComputers
    
}

#Get Users and Groups in Remote Dekstop Users and Admin
function CheckAccess {
    param (
        OptionalParameters
    )

    
    
}



#Compare users against the group to see if the users is present inside


#Remove User if user is not on the group