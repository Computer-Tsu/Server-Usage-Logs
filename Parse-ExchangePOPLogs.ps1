<#
.SYNOPSIS
    Parses Exchange POP logs for unique client IPs.

.DESCRIPTION
    - Scans *.log files from POP3 log folder.
    - Extracts IPv4 addresses.
    - Optional CSV or plain text output.
    - Displays a progress indicator.

.PARAMETER LogFolder
    Path to Exchange POP log folder

.PARAMETER Csv
    Output to ParsedIPs-POP.csv with IP frequency count

.PARAMETER NoProgress
    Disable the progress bar

.EXAMPLE
    .\Parse-ExchangePOPLogs.ps1 -Csv
#>

param (
    [string]$LogFolder = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\POP3\",
    [switch]$Csv,
    [switch]$NoProgress
)

Write-Host "Parsing Exchange POP logs from: $LogFolder"

if (-Not (Test-Path $LogFolder)) {
    Write-Warning "POP log folder not found: $LogFolder"
    Write-Host "POP logging must be enabled in Exchange transport settings."
    exit 1
}

$outputCsv = "ParsedIPs-POP.csv"
$outputTxt = "ParsedIPs-POP.txt"
$ipCount = @{}
$ipRegex = '\b(?:(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\b'
$files = Get-ChildItem -Path $LogFolder -Filter *.log
$total = $files.Count
$count = 0

foreach ($file in $files) {
    $count++
    if (-not $NoProgress -and ($count % 1 -eq 0)) {
        Write-Progress -Activity "Parsing POP Logs" -Status "$count of $total files" -PercentComplete (($count / $total) * 100)
    }

    Get-Content $file.FullName | ForEach-Object {
        $matches = [regex]::Matches($_, $ipRegex)
        foreach ($match in $matches) {
            $ip = $match.Value
            if ($ipCount.ContainsKey($ip)) { $ipCount[$ip]++ }
            else { $ipCount[$ip] = 1 }
        }
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
