# Purpose:  Veeam Powershell SQL Explorer based database redirected restore to
#           refresh and rename database between source and destination database servers
#           using default SQL Server instance
#
# Pre-req:  Veeam Enterprise Backup & Recovery Console installed on server 
#           the powershell script is running on
#
# Author:   jw7777777
#
# License:  MIT 

[cmdletbinding()]
Param()

# Check if Veeam.Backup.PowerShell module is loaded, if not, load it
$vbr_psmodule_check = Get-Module -Name Veeam.Backup.PowerShell
if ($null -eq $vbr_psmodule_check)
{
  Import-Module Veeam.Backup.PowerShell -ErrorAction SilentlyContinue
}

# Check if Veeam.SQL.PowerShell module is loaded, if not, load it
$vbrsql_psmodule_check = Get-Module -Name Veeam.SQL.PowerShell
if ($null -eq $vbrsql_psmodule_check)
{
  Import-Module Veeam.SQL.PowerShell -ErrorAction SilentlyContinue
}

# Veeam Backup Server
$vbr_server = "veeambr01"

# Source database name and DB server
$src_dbname = "JWTEST"
$src_dbserver = "server01*"

# Destination database name,DB server and redirected restore file path
$dst_dbname = "JWTESTRESTORED"
$dst_dbserver = "server02"
$dst_dbserver_restore_filepath = @("E:\MSSQL\Default\Data\JWTESTRESTORED.mdf","F:\MSSQL\Default\Log\JWTESTRESTORED_log.ldf")



try {
  Write-Verbose "Attempting connection to Veeam backup server..."
  Connect-VBRServer -Server $vbr_server -ErrorAction Stop
}
catch {
  Write-Error "Unable to connect to Veeam server: $Error[0]"
  Stop-VESQLRestoreSession -Session $vrs
}


# Locate most recent SQL backup from Veeam image backup (we aren't doing point-in-time recovery)
try {
  Write-Verbose "Locating most recent SQL backup from Veeam image backup"
  $dbrp = Get-VBRApplicationRestorePoint -SQL -Name $src_dbserver | Sort-Object creationtime | Select-Object -Last 1 -ErrorAction Stop
}
catch {
  Write-Error "Unable to locate SQL backup to restore from: $Error[0]"
  Stop-VESQLRestoreSession -Session $vrs
}

# Start Veeam Explorer session and locate database to restore
try {
  Write-Verbose "Starting Veeam Explorer session"
  $vrs = Start-VESQLRestoreSession -RestorePoint $dbrp -ErrorAction Stop
}
catch {
  Write-Error "Unable to start Veeam Explorer session: $Error[0]"
  Stop-VESQLRestoreSession -Session $vrs
}

try {
  Write-Verbose "Getting database name to restore"
  $database = Get-VESQLDatabase -Session $vrs -Name $src_dbname -ErrorAction Stop
}
catch {
  Write-Error "Unable to find database name to restore: $Error[0]"
  Stop-VESQLRestoreSession -Session $vrs
}


# Redirected restore, force overwrite if DB already exists

$files = Get-VESQLDatabaseFile -Database $database

# See Veeam Powershell documentation to revise below 
# if you need to restore to a named instance. 
# Using default instance below 
try {
  Write-Verbose "Starting $dst_dbname database restore"
  Restore-VESQLDatabase -Database $database -DatabaseName $dst_dbname -ServerName $dst_dbserver -File $files -TargetPath $dst_dbserver_restore_filepath -Force -ErrorAction Stop
}
catch {
  Write-Error "Unable to restore database: $Error[0]"
  Stop-VESQLRestoreSession -Session $vrs
}


## Stop restore session
Stop-VESQLRestoreSession -Session $vrs
Disconnect-VBRServer


# References:
# https://helpcenter.veeam.com/docs/backup/explorers_powershell/veeam_explorer_for_microsoft_sql.html?ver=110
