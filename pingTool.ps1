<#
.SYNOPSIS
    Continuous ping monitoring tool with logging capabilities.

.DESCRIPTION
    This script provides a continuous ping monitoring solution that logs results to both
    the console and a text file. It calculates and displays statistics including minimum,
    maximum, and average response times. Results are stored in the user's Documents folder in a
    dedicated "PingTool" directory, with each session logged in a timestamped file.

.NOTES
    File Name      : PIngTool.ps1
    Author         : MgramTheDuck
    Prerequisite   : PowerShell 5.1 or later
    Created        : June 22, 2025
    Version        : 1.0

.EXAMPLE
    .\PIngTool.ps1
    Runs the script and prompts for an IP address or hostname to monitor

.LINK
    https://github.com/MgramTheDuck/PingTool
#>

$ip = Read-Host "Enter the IP address or hostname to ping"
$logDir = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PingTool'
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}
$logFile = Join-Path -Path $logDir -ChildPath ("PingLog_$((Get-Date -Format 'yyyyMMdd_HHmmss')).txt")

# Create initialization message with header
$initMessage = @"
==========================================================
Ping Log Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Target: $ip
==========================================================
"@

# Write initialization to console and log file
Write-Host $initMessage -ForegroundColor Cyan
Add-Content -Path $logFile -Value $initMessage

Write-Host "Pinging $ip. Logging output to $logFile. Press Ctrl+C to stop."

$pingCount = 0
$successCount = 0
$failCount = 0
$totalTime = 0
$minTime = [int]::MaxValue
$maxTime = 0

while ($true) {
    $pingCount++
    $result = Test-Connection -ComputerName $ip -Count 1 -ErrorAction SilentlyContinue
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    
    if ($result) {
        $time = $result.Latency
        $status = $result.Status
        $address = $result.Address
        $bufferSize = $result.BufferSize
        
        $successCount++
        $totalTime += $time
        $minTime = [Math]::Min($minTime, $time)
        $maxTime = [Math]::Max($maxTime, $time)
        $avgTime = [Math]::Round($totalTime / $successCount, 2)
        
        $msg = "$timestamp - Reply from $address : Latency=${time}ms, Status=$status, Buffer=$bufferSize bytes, Min=${minTime}ms, Max=${maxTime}ms, Avg=${avgTime}ms"
    } else {
        $failCount++
        $msg = "$timestamp - Request to $ip failed. Successful pings: $successCount/$pingCount"
    }
    
    Write-Host $msg
    Add-Content -Path $logFile -Value $msg
    Start-Sleep -Seconds 1
}
