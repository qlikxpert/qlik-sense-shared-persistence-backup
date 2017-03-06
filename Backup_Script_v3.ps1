# First drop all the restrictions on script execution

Set-ExecutionPolicy Unrestricted 

$Today = Get-Date -UFormat "%Y%m%d_%H%M"
 
$StartTime = Get-Date -UFormat "%Y%m%d_%H%M"
 
$PostGreSQLLocation = "D:\Program Files\Qlik\Sense\Repository\PostgreSQL\9.3\bin"
$PostGresBackupTarget = “E:\Backups\Qlik"
$SenseProgramData = "D:\QlikShared\" # Shared Persistance Folder
 
 
$Today = Get-Date -UFormat "%Y%m%d_%H%M"
 
$StartTime = Get-Date -UFormat "%Y%m%d_%H%M"
 

# --blobs , exclude for now
 
write-host "Stopping Qlik Services ...."
 
stop-service QlikSenseProxyService -WarningAction SilentlyContinue
Start-Sleep -s 10
stop-service QlikSenseEngineService -WarningAction SilentlyContinue
Start-Sleep -s 10
stop-service QlikSenseSchedulerService -WarningAction SilentlyContinue
Start-Sleep -s 10
stop-service QlikSensePrintingService -WarningAction SilentlyContinue
Start-Sleep -s 10
stop-service QlikSenseServiceDispatcher -WarningAction SilentlyContinue
Start-Sleep -s 10
stop-service QlikSenseRepositoryService -WarningAction SilentlyContinue
 
Copy-Item  $SenseProgramData\ArchivedLogs -Destination $PostGresBackupTarget\$StartTime\ArchivedLogs -Recurse
Copy-Item  $SenseProgramData\Apps -Destination $PostGresBackupTarget\$StartTime\Apps -Recurse
Copy-Item  $SenseProgramData\StaticContent -Destination $PostGresBackupTarget\$StartTime\StaticContent -Recurse
Copy-Item  $SenseProgramData\CustomData -Destination $PostGresBackupTarget\$StartTime\CustomData -Recurse
 
write-host "File Backup Completed"
 
write-host "Backing up PostgreSQL Repository Database ...."
 
cd $PostGreSQLLocation
.\pg_dump.exe -h localhost -p 4432 -U postgres -w -F t -f "$PostGresBackupTarget\$StartTime\QSR_backup_$Today.tar" QSR
 
write-host "PostgreSQL backup Completed"
 
write-host "Backing up Shared Persistance Data from $SenseProgramData ...."
 
write-host "Restarting Qlik Services ...."
 
start-service QlikSenseRepositoryService -WarningAction SilentlyContinue
Start-Sleep -s 10
start-service QlikSenseEngineService -WarningAction SilentlyContinue
Start-Sleep -s 10
start-service QlikSenseSchedulerService -WarningAction SilentlyContinue
Start-Sleep -s 10
start-service QlikSensePrintingService -WarningAction SilentlyContinue
Start-Sleep -s 10
start-service QlikSenseServiceDispatcher -WarningAction SilentlyContinue
Start-Sleep -s 10
start-service QlikSenseProxyService -WarningAction SilentlyContinue
 
$EndTime = Get-Date -UFormat "%Y%m%d_%H%M%S"
 
write-host "This backup process started at " $StartTime " and ended at " $EndTime
 
 
# Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
 
# Delete any empty directories left behind after deleting the old files.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse