#Get Variables
. .\variables.ps1

#Tableau Maintenance for Logs

#TSM commands to create ziplogs
SET logfilename = Tableau_Logs
SET newlogfilename=%logfilename%_%date:~-4,4%-%date:~-7,2%-%date:~-10,2%

tsm maintenance ziplogs -f %logfilename% --all

move /y "filepath" f:\tsbackup\%newlogfilename%.zip

tsm maintenance cleanup

Start-Sleep -Seconds 7200

#Remove Log files that are 60 days old.
$logsToDelete = Get-ChildItem -Path $logDirectory -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-60)}
#Remove backups that are 14 days old.
$backupToDelete = Get-ChildItem -Path $backupDirectory -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-14)}

#Clear logs and backup files
if ($logsToDelete -or $backupToDelete -eq $true) {

    try {
        
        Write-Host "Deleting Backup files...." -ForegroundColor Green
        foreach ($item in $backupToDelete) {
            Write-Host "Deleting $($item.Name)..." -ForegroundColor Yellow
            remove-item -Path $item -Force -Verbose
            Write-Host "File $($file.Name) has been removed...."
            $count++

        }
        Write-Host "Deleting Backup files...."
        foreach ($log in $logsToDelete) {
            Write-Host "Deleting $($log.Name)..." -ForegroundColor Yellow
            Remove-Item -Path $log -Force -Verbose
            Write-Host "File $($log.Name) has been removed...."
            $count++
        }
    }
    catch {

        Write-Host "Failed to delete files." -ForegroundColor Red
        BREAK
    }

}
else {
    Write-Host "No files match the criteria to be deleted..." -ForegroundColor Red
}

#Add send email.