<#
.SYNOPSIS
    Parses Exchange IMAP logs for unique client IPs.

.DESCRIPTION
    - Reads all log files in the IMAP4 folder.
    - Extracts IPv4 addresses.
    - Supports plain text or CSV output.
    - Displays optional progress bar.

.PARAMETER LogFolder
    Path to Exchange IMAP log folder

.PARAMETER Csv
    Output to ParsedIPs-IMAP.csv with frequency counts

.PARAMETER NoProgress
    Disable the progress bar

.EXAMPLE
    .\Parse-ExchangeIMAPLogs.ps1 -Csv
#>

param (
    [string]$LogFolder = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\IMAP4\",
    [switch]$Csv,
    [switch]$NoProgress
)

Write-Host "Parsing Exchange IMAP logs from: $LogFolder"

if (-Not (Test-Path $LogFolder)) {
    Write-Warning "IMAP log folder not found: $LogFolder"
    Write-Host "IMAP logging must be enabled in Exchange transport settings."
    exit 1
}

$outputCsv = "ParsedIPs-IMAP.csv"
$outputTxt = "ParsedIPs-IMAP.txt"
$ipCount = @{}
$ipRegex = '\b(?:(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\b'
$files = Get-ChildItem -Path $LogFolder -Filter *.log
$total = $files.Count
$count = 0

foreach ($file in $files) {
    $count++
    if (-not $NoProgress -and ($count % 1 -eq 0)) {
        Write-Progress -Activity "Parsing IMAP Logs" -Status "$count of $total files" -PercentComplete (($count / $total) * 100)
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
