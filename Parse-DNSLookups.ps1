<#
.SYNOPSIS
    Extracts requested domain names from Windows DNS debug logs.

.DESCRIPTION
    - Parses DNS debug logs for lines that contain DNS query requests.
    - Extracts host.domain names (FQDNs).
    - Deduplicates and sorts them.
    - Saves output to ParsedNames-DNS.txt.
#>

param (
    [string]$LogFile = "C:\Windows\System32\dns\dns.log"
)

Write-Host "Parsing DNS log file for requested hostnames: $LogFile"

if (-Not (Test-Path $LogFile)) {
    Write-Error "DNS log file not found: $LogFile"
    exit 1
}

$outputFile = Join-Path -Path (Get-Location) -ChildPath "ParsedNames-DNS.txt"
$nameRegex = '\b([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}\b'  # Matches domain names
$queries = @()

# Read all lines and track total
$lines = Get-Content $LogFile
$total = $lines.Count
$counter = 0

foreach ($line in $lines) {
    $counter++
    Write-Progress -Activity "Scanning DNS Requests" -Status "$counter of $total" -PercentComplete (($counter / $total) * 100)

    # Look for lines that appear to represent DNS queries
    if ($line -match "Query for|received name query|QRY") {
        $matches = [regex]::Matches($line, $nameRegex)
        foreach ($match in $matches) {
            $queries += $match.Value.ToLower()
        }
    }
}

$queries | Sort-Object | Get-Unique | Tee-Object -FilePath $outputFile
Write-Host "Saved requested hostnames to: $outputFile"
