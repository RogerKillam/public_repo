<#
    .SYNOPSIS
    Get-Capture is a PowerShell script used to demonstrate how one can capture network traffic, filter the captured traffic, and publish the results to SQL Server.
    In this example, the BACnet network protocol is being tested for successful communication between a collector server and BACnet devices.
    There are 3 collectors, each logging historical BACnet device telemetry for reporting and analysis.
    .Notes
    Roger Killam, 2022.02.13
    rok@sp99.io
    .LINK
    https://docs.microsoft.com/en-us/powershell/module/neteventpacketcapture/?view=windowsserver2022-ps
#>

$collector = $env:computername
$collectors = 'collector01', 'collector02', 'collector03'
$session = "getcap"
$provider = "Microsoft-Windows-TCPIP"
$log_path = "C:\"
$log = $log_path + 'getcap.etl'
$csv = $log_path + 'getcap.csv'

# collector server check
if ($collector -inotin $collectors) {
    Write-Host "The system $collector is not recognized as a BACnet collector."
    break
}

# remove previous logs
$elt_check = Test-Path $log
if ($elt_check -eq $True) {
    Remove-Item -Path $log
}

$csv_check = Test-Path $csv
if ($csv_check -eq $True) {
    Remove-Item -Path $csv
}

# create a new session
New-NetEventSession -Name $session -CaptureMode SaveToFile -LocalFilePath $log -MaxFileSize 2

# add a provider
logman.exe query providers | Select-String tcp
Add-NetEventProvider -Name $provider -SessionName $session

# start the session
Start-NetEventSession -Name $session

# pause for capture
Start-Sleep -Seconds 30

# stop the session
Stop-NetEventSession -Name $session
Remove-NetEventSession -Name $session

# filter the log for BACnet traffic
$header = 'message_udp_endpoint,source,source_address_and_port,destination,destination_address_and_port,bytes_delivered,pid'
$header | Out-File -FilePath $csv -NoNewline

$capture = Get-WinEvent -Path $log -Oldest
$filter = $capture.Where({$_.Message -match '47808' -or $_.Message -match '48808' -or $_.Message -match '47815' -and $_.Message -match 'delivering'}) |
    Sort-Object Message |
    Format-List Message |
    Out-String

$format = $filter
$format = $format.Replace("Message : UDP: endpoint ","")
$format = $format.Replace(" (",",")
$format = $format.Replace(")",",")
$format = $format.Replace(" = ",",")
$format = $format.Replace("delivering","")
$format = $format.Replace("bytes. PID","")
$format = $format.Replace(" ","")
$format = $format.Replace("`r`n","`n")

$format | Out-File -FilePath $csv -Append -NoNewline

# check for the SqlServer module
if (Get-Module -ListAvailable -Name SqlServer) {
    Write-Host "The SqlServer module is installed."
} 
else {
    try {
        Install-Module -Name SqlServer -AllowClobber -Confirm:$False -Force  
    }
    catch [Exception] {
        $_.message 
        exit
    }
}

# set sql server parameters and insert records
$sql_server_name = 'localhost'
$database_name = 'collector_checks'
$table_name = '[dbo].[collector_' + $collector + '_check]'
$log_table_name = 'collector_check_log'
$count = 1

# clear previous collector check and log transaction
$record_timestamp = Get-Date -Format "yyyy/MM/dd/ HH:mm:ss.ms"

$query = "
            DELETE FROM $table_name;
            INSERT INTO $log_table_name([record_timestamp],[action])
            VALUES ('$record_timestamp','$collector' + ' check executed');
"

Invoke-Sqlcmd -Database $database_name -Query $query -ServerInstance $sql_server_name

# insert records
$csv_log = Import-Csv -Path $csv

foreach ($i in $csv_log) {
    $record_timestamp = Get-Date -Format "yyyy/MM/dd/ HH:mm:ss.ms"
    $source_address_and_port = $i."source_address_and_port"
    $destination_address_and_port = $i."destination_address_and_port"
    $bytes_delivered = $i."bytes_delivered"

    $query = "
                INSERT INTO $table_name([record_timestamp],[collector],[source_address_and_port],[destination_address_and_port],[bytes_delivered])
                VALUES ('$record_timestamp','$collector','$source_address_and_port','$destination_address_and_port','$bytes_delivered');
    "
    
    Invoke-Sqlcmd -Database $database_name -Query $query -ServerInstance $sql_server_name
    
    $count = $count + 1
}

# log transaction complete
$record_timestamp = Get-Date -Format "yyyy/MM/dd/ HH:mm:ss.ms"

$query = "
            INSERT INTO $log_table_name([record_timestamp],[action])
            VALUES ('$record_timestamp','$collector' + ' check complete');
"

Invoke-Sqlcmd -Database $database_name -Query $query -ServerInstance $sql_server_name
