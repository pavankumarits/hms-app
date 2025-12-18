$date = Get-Date -Format "yyyyMMdd-HHmm"
$backupDir = "C:\HospitalData\Backups\$date"
$mysqlUser = "root"
$mysqlPwd = "password"
$dbName = "hms_db"
$filesSource = "C:\HospitalData\Reports"

# Create backup directory
New-Item -ItemType Directory -Force -Path $backupDir

# Backup MySQL Database
# Note: mysqldump must be in PATH or specify full path
Write-Host "Backing up Database..."
mysqldump -u $mysqlUser -p$mysqlPwd $dbName > "$backupDir\hms_db_backup.sql"

# Backup Files
Write-Host "Backing up Files..."
Copy-Item -Path $filesSource -Destination $backupDir -Recurse

Write-Host "Backup Complete at $backupDir"
