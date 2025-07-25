<#
.SYNOPSIS
    Extracts requested FQDNs from Windows DNS debug logs.

.DESCRIPTION
    - Parses lines matching DNS queries from dns.log
    - Extracts FQDNs (fully qualified domain names)
    - Supports optional CSV output: domain,count sorted by count descending
    - Optionally disables the progress bar for better performance

.PARAMETER LogFile
    Path to the DNS debug log file (default: C:\Windows\System32\dns\dns.log)

.PARAMETER Csv
    Outputs results as ParsedNames-DNS.csv with unique domain,count sorted by count descending

.PARAMETER NoProgress
    Disables progress bar for faster parsing

.NOTES
    To enable DNS debug logging:
    - Open DNS Manager > server properties > Debug Logging tab
    - Enable “Log packets for queries and responses”
    - Default path: C:\Windows\System32\dns\dns.log

.EXAMPLE
    .\Parse-DNSRequests.ps1
    .\Parse-DNSRequests.ps1 -Csv
    .\Parse-DNSRequests.ps1 -LogFile "D:\Logs\dns.log" -Csv -NoProgress
#>

param (
    [string]$LogFile = "C:\Windows\System32\dns\dns.log",
    [switch]$Csv,
    [switch]$NoProgress
)

Write-Host "Parsing DNS log file: $LogFile"

if (-Not (Test-Path $LogFile)) {
    Write-Warning "DNS log file not found: $LogFile"
    Write-Host "`nTo enable DNS logging:"
    Write-Host "1. Open DNS Manager"
    Write-Host "2. Right-click server > Properties > Debug Logging tab"
    Write-Host "3. Enable 'Log packets for queries and responses'"
    Write-Host "4. Default file: C:\Windows\System32\dns\dns.log"
    exit 1
}

$nameRegex = '\b([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}\b'
$lines = Get-Content $LogFile
$total = $lines.Count
$counter = 0
$nameHash = @{}

foreach ($line in $lines) {
    $counter++
    if (-not $NoProgress -and ($counter % 500 -eq 0)) {
        Write-Progress -Activity "Scanning DNS log" -Status "$counter of $total" -PercentComplete (($counter / $total) * 100)
    }

    if ($line -match "Query for|received name query|QRY") {
        $matches = [regex]::Matches($line, $nameRegex)
        foreach ($match in $matches) {
            $name = $match.Value.ToLower()
            if ($nameHash.ContainsKey($name)) {
                $nameHash[$name]++
            } else {
                $nameHash[$name] = 1
            }
        }
    }
}

if ($Csv) {
    $csvFile = Join-Path -Path (Get-Location) -ChildPath "ParsedNames-DNS.csv"
    $nameHash.GetEnumerator() |
        Sort-Object -Property Value -Descending |
        Select-Object @{Name="Domain";Expression={$_.Key}}, @{Name="Count";Expression={$_.Value}} |
        Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
    Write-Host "Saved CSV output to: $csvFile"
} else {
    $txtFile = Join-Path -Path (Get-Location) -ChildPath "ParsedNames-DNS.txt"
    $nameHash.Keys | Sort-Object | Get-Unique | Tee-Object -FilePath $txtFile
    Write-Host "Saved unique domain names to: $txtFile"
}
