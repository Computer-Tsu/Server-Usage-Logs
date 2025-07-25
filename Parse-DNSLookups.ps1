<#
.SYNOPSIS
    Extracts requested domain names (FQDNs) from Windows DNS debug logs.

.DESCRIPTION
    - Parses DNS debug logs typically located at C:\Windows\System32\dns\dns.log
    - Extracts FQDNs from DNS query lines (Query for, QRY, etc.)
    - Deduplicates and sorts them
    - Optionally disables progress bar for performance

.PARAMETER LogFile
    Full path to the DNS debug log file

.PARAMETER NoProgress
    If specified, disables the progress indicator for faster parsing

.OUTPUT
    Writes results to ParsedNames-DNS.txt in current working directory

.NOTES
    To enable DNS debug logging:
    - Open DNS Manager
    - Right-click your server > Properties > Debug Logging tab
    - Enable logging and select query types (e.g., incoming/outgoing, packets, queries)
    - Default file: %SystemRoot%\System32\dns\dns.log

.EXAMPLE
    .\Parse-DNSRequests.ps1
    .\Parse-DNSRequests.ps1 -LogFile "D:\logs\dns.log" -NoProgress
#>

param (
    [string]$LogFile = "C:\Windows\System32\dns\dns.log",
    [switch]$NoProgress
)

Write-Host "Parsing DNS log file: $LogFile"
if (-Not (Test-Path $LogFile)) {
    Write-Warning "Log file not found: $LogFile"
    Write-Host "`nTo enable DNS logging:"
    Write-Host "1. Open DNS Manager"
    Write-Host "2. Right-click your server > Properties > Debug Logging tab"
    Write-Host "3. Enable logging of packet and query types"
    Write-Host "4. Default log file: C:\Windows\System32\dns\dns.log"
    exit 1
}

$outputFile = Join-Path -Path (Get-Location) -ChildPath "ParsedNames-DNS.txt"
$nameRegex = '\b([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}\b'
$queries = @()

$lines = Get-Content $LogFile
$total = $lines.Count
$counter = 0

foreach ($line in $lines) {
    $counter++

    if (-not $NoProgress -and ($counter % 500 -eq 0)) {
        Write-Progress -Activity "Scanning DNS log" -Status "$counter of $total" -PercentComplete (($counter / $total) * 100)
    }

    if ($line -match "Query for|received name query|QRY") {
        $matches = [regex]::Matches($line, $nameRegex)
        foreach ($match in $matches) {
            $queries += $match.Value.ToLower()
        }
    }
}

$queries | Sort-Object | Get-Unique | Tee-Object -FilePath $outputFile
Write-Host "Saved unique hostnames to: $outputFile"
