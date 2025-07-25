<#
.SYNOPSIS
    Parses DNS debug log for unique client IP addresses with progress bar.

.DESCRIPTION
    - Scans the DNS debug log for all IPv4 addresses using regex.
    - Displays progress bar while reading lines.
    - Deduplicates and sorts output.
    - Saves results to a file in the current directory.
#>

param (
    [string]$LogFile = "C:\Windows\System32\dns\dns.log"
)

Write-Host "Parsing DNS debug log: $LogFile"

if (-Not (Test-Path $LogFile)) {
    Write-Error "DNS log file not found: $LogFile"
    exit 1
}

$outputFile = Join-Path -Path (Get-Location) -ChildPath "ParsedIPs-DNS.txt"
$ipRegex = '\b(?:(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\b'
$ipList = @()

# Read all lines first to count total
$lines = Get-Content $LogFile
$totalLines = $lines.Count
$counter = 0

foreach ($line in $lines) {
    $counter++
    Write-Progress -Activity "Scanning DNS log" -Status "$counter of $totalLines" -PercentComplete (($counter / $totalLines) * 100)

    $matches = [regex]::Matches($line, $ipRegex)
    foreach ($match in $matches) {
        $ipList += $match.Value
    }
}

$ipList | Sort-Object | Get-Unique | Tee-Object -FilePath $outputFile
Write-Host "Saved parsed IPs to: $outputFile"
