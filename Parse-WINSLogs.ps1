<#
.SYNOPSIS
    Parses WINS log for client IP addresses.

.DESCRIPTION
    - Extracts all IPv4 addresses from WINS log.
    - Supports optional CSV output sorted by count.
    - Shows progress unless disabled.

.PARAMETER LogFile
    Path to the WINS log file

.PARAMETER Csv
    Output IP frequency to ParsedIPs-WINS.csv

.PARAMETER NoProgress
    Disable progress bar

.EXAMPLE
    .\Parse-WINSLogs.ps1 -Csv
#>

param (
    [string]$LogFile = "C:\Windows\System32\WINS\wins.log",
    [switch]$Csv,
    [switch]$NoProgress
)

Write-Host "Parsing WINS log file: $LogFile"

if (-Not (Test-Path $LogFile)) {
    Write-Warning "WINS log file not found: $LogFile"
    Write-Host "`nTo enable WINS logging:"
    Write-Host "1. Open Services.msc > Start the WINS service"
    Write-Host "2. Configure WINS logging under administrative tools"
    exit 1
}

$outputCsv = "ParsedIPs-WINS.csv"
$outputTxt = "ParsedIPs-WINS.txt"
$ipCount = @{}
$lines = Get-Content $LogFile
$total = $lines.Count
$counter = 0
$ipRegex = '\b(?:(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\b'

foreach ($line in $lines) {
    $counter++
    if (-not $NoProgress -and ($counter % 500 -eq 0)) {
        Write-Progress -Activity "Parsing WINS Log" -Status "$counter of $total lines" -PercentComplete (($counter / $total) * 100)
    }

    $matches = [regex]::Matches($line, $ipRegex)
    foreach ($match in $matches) {
        $ip = $match.Value
        if ($ipCount.ContainsKey($ip)) { $ipCount[$ip]++ }
        else { $ipCount[$ip] = 1 }
    }
}

if ($Csv) {
    $ipCount.GetEnumerator() |
        Sort-Object -Property Value -Descending |
        Select-Object @{Name="IP";Expression={$_.Key}}, @{Name="Count";Expression={$_.Value}} |
        Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8
    Write-Host "Saved CSV output to: $outputCsv"
} else {
    $ipCount.Keys | Sort-Object | Get-Unique | Tee-Object -FilePath $outputTxt
    Write-Host "Saved plain text output to: $outputTxt"
}
