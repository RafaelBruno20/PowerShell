#Get Values from variables files.
. .\variables.ps1

function appregDelete {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateRange(1,90)]
        [int]$range,

        [Parameter(Mandatory=$true)]
        [string]$clientID,

        [Parameter(Mandatory=$true)]
        [string]$tenantID,

        [Parameter(Mandatory=$true)]
        [string]$certificateThumbprint
        
    )

    try {

        #Connect to Graph
        Connect-MgGraph -TenantId $tenantID -ClientId $clientID -CertificateThumbprint $certificateThumbprint
        Get-MgContext | Out-Null
        $application = Get-MgApplication -All
        foreach ($app in $application) {
            <#
            Need to establish that a secret value actually exist.
            If secret value doesn't exist skip the app.
            #>
            $secret = $app.PasswordCredentials.EndDateTime
            if ($null -ne $secret) {
                #Get date
                $todayDate = Get-Date
                #Some apps have more then 1 certificate, therefore we need to calculate the amount on entries that the PasswordCredentials.EndDateTime provides.
                $renewal = $app.PasswordCredentials.EndDateTime
                $arrayRenewal = @($renewal)
                $amountSecret = $arrayRenewal.Count
    
                if ($amountSecret -eq 1) {
                    $timeDifferent = New-TimeSpan -Start $renewal -End $todayDate
                    $days = $timeDifferent.Days
                    if ($days -gt $range) {
                        Write-Host "Application $($app.DisplayName) and ID $($app.Id) has experied $($days) ago." -ForegroundColor Red
                        Write-Output "Application $($app.DisplayName) and ID $($app.AppId) will be removed." | Out-File -FilePath "C:\GitClone\remove_list.txt" -Append
                        #Use ObjectID instead of ApplicationID (ClientID)
                        Remove-MgApplication -ApplicationId $app.Id -Verbose
                        Write-Host "Application $($app.DisplayName) has been removed" -ForegroundColor DarkGreen
                    }
                    else {
                        Write-Host "Application $($app.DisplayName) is still good!" -ForegroundColor Green
                    }
                }

                if ($amountSecret -gt 1 -or $null -eq $amountSecret) {
                    Write-Host "Application $($app.DisplayName) and ID $($app.AppId) ignore!" -ForegroundColor DarkBlue
                }
                 
            }
            else {
                Write-Host "Application $($app.DisplayName) doesn't have a secret value. Skipping..." -ForegroundColor Yellow

            }
            
        }
    
    }
    catch {
        $message = $_
        Write-Host "ERROR: $message" -ForegroundColor Red
    
    }
    
}

appregDelete -ClientId $clientID -TenantId $tenantID -certificateThumbprint $certificateThumbprint -range 30


