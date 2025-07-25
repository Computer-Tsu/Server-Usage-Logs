<#
.SYNOPSIS
    Parses IIS W3C logs to extract client IP addresses.

.DESCRIPTION
    - Scans .log files from the IIS log folder.
    - Extracts 'c-ip' field (client IP).
    - Supports plain text or CSV output sorted by frequency.
    - Displays progress bar (optional).
    - Handles missing log folders gracefully.

.PARAMETER LogFolder
    Path to the IIS log folder (default: C:\inetpub\logs\LogFiles)

.PARAMETER Csv
    Outputs frequency counts to ParsedIPs-IIS.csv (IP,Count)

.PARAMETER NoProgress
    Disables the progress bar for faster execution

.EXAMPLE
    .\Parse-IISLogs.ps1
    .\Parse-IISLogs.ps1 -Csv
    .\Parse-IISLogs.ps1 -LogFolder "D:\Logs\IIS" -Csv -NoProgress
#>

param (
    [string]$LogFolder = "C:\inetpub\logs\LogFiles",
    [switch]$Csv,
    [switch]$NoProgress
)

Write-Host "Parsing IIS logs from folder: $LogFolder"

if (-Not (Test-Path $LogFolder)) {
    Write-Warning "The specified IIS log folder does not exist: $LogFolder"
    Write-Host "To enable IIS logging:"
    Write-Host "1. Open IIS Manager > Select site > Logging"
    Write-Host "2. Ensure 'Format: W3C' and a valid log path are set"
    exit 1
}

$ipRegex = '^\d{4}-\d{2}-\d{2}|\b(?:\d{1,3}\.){3}\d{1,3}\b'
$ipCount = @{}
$files = Get-ChildItem -Path $LogFolder -Recurse -Filter *.log
$total = $files.Count
$counter = 0

foreach ($file in $files) {
    $counter++
    if (-not $NoProgress -and ($counter % 1 -eq 0)) {
        Write-Progress -Activity "Parsing IIS Logs" -Status "$counter of $total files" -PercentComplete (($counter / $total) * 100)
    }

    Get-Content $file.FullName | ForEach-Object {
        if ($_ -notmatch "^#") {
            $fields = $_ -split '\s+'
            if ($fields.Length -gt 0) {
                $ip = $fields[0]
                if ($ip -match '^\d{1,3}(\.\d{1,3}){3}$') {
                    if ($ipCount.ContainsKey($ip)) {
                        $ipCount[$ip]++
                    } else {
                        $ipCount[$ip] = 1
                    }
                }
            }
        }
    }
}

if ($Csv) {
    $csvFile = Join-Path -Path (Get-Location) -ChildPath "ParsedIPs-IIS.csv"
    $ipCount.GetEnumerator() |
        Sort-Object -Property Value -Descending |
        Select-Object @{Name="IP";Expression={$_.Key}}, @{Name="Count";Expression={$_.Value}} |
        Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
    Write-Host "Saved CSV output to: $csvFile"
} else {
    $txtFile = Join-Path -Path (Get-Location) -ChildPath "ParsedIPs-IIS.txt"
    $ipCount.Keys | Sort-Object | Get-Unique | Tee-Object -FilePath $txtFile
    Write-Host "Saved unique IPs to: $txtFile"
}
