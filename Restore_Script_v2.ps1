#When performing the procedure below you must log on using an account 
#that had the root admin role in the site when it was backed up. If you 
#log on using a local admin account and the machine name is different, 
#your permissions will not follow through.

# First drop all the restrictions on script execution

Set-ExecutionPolicy Unrestricted 

$StartTime = Get-Date -UFormat "%Y%m%d_%H%M"
$EndTime = Get-Date -UFormat "%Y%m%d_%H%M%S"
$BackupFile = Read-Host -Prompt 'Input the backup string you wish to restore'
Start-Sleep -s 60
$PostGreSQLLocation = "D:\Program Files\Qlik\Sense\Repository\PostgreSQL\9.3\bin"
$PostGresBackupLocaton = “E:\Backups\Qlik\$BackupFile"
$SenseProgramData = "D:\QlikShared\" # Shared Persistance Folder
$Today = Get-Date -UFormat "%Y%m%d_%H%M"
$StartTime = Get-Date -UFormat "%Y%m%d_%H%M"
$PostGresDBFile = “E:\Backups\Qlik\$BackupFile\QSR_backup_$BackupFile.tar"


# kill off all of the services except the qlik sense repository service.

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

# navigate to the database directory

cd $PostGreSQLLocation

write-host "Restoring PostgreSQL Repository Database ...."

# drop the database and restore from the backup

.\dropdb.exe -e -h localhost -p 4432 -U postgres -w QSR

.\createdb.exe -h localhost -p 4432 -U postgres -T template0 QSR

.\pg_restore.exe -h localhost -p 4432 -U postgres -d QSR $PostGresDBFile

write-host "PostgreSQL Restore Completed"

# restore the appliction folders

write-host "Restoring Shared Persistence Data from $PostGresBackupLocaton ...."

#Restore log and application data to the file share used for storage of log and application data.

Copy-Item $PostGresBackupLocaton\ArchivedLogs -Destination $SenseProgramData\ArchivedLogs -Recurse -Force
Copy-Item $PostGresBackupLocaton\Apps -Destination $SenseProgramData\Apps -Recurse -Force 
Copy-Item $PostGresBackupLocaton\StaticContent -Destination  $SenseProgramData\StaticContent -Recurse -Force
Copy-Item $PostGresBackupLocaton\CustomData -Destination $SenseProgramData\CustomData -Recurse -Force

write-host "File Restore Completed"

write-host "Restarting Qlik Services ...."

# restart the services

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

write-host "This restore process started at " $StartTime " and ended at " $EndTime