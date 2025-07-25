<#
.SYNOPSIS
    Parses WINS log file for unique client IP addresses.

.DESCRIPTION
    - Reads the WINS log file (default or custom path)
    - Uses regex to extract IP addresses
    - Deduplicates, sorts, and saves output
#>

param (
    [string]$LogFile = "C:\Windows\System32\WINS\wins.log"
)

# Print the log file being used
Write-Host "Parsing WINS log file: $LogFile"

# Validate log file
if (-Not (Test-Path $LogFile)) {
    Write-Error "WINS log file not found: $LogFile"
    exit 1
}

# Prepare output
$outputFile = Join-Path -Path (Get-Location) -ChildPath "ParsedIPs-WINS.txt"
$ipRegex = '\b(?:(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(?:\.|$)){4}\b'
$ipList = @()

# Read and process file
Get-Content $LogFile | ForEach-Object {
    $matches = [regex]::Matches($_, $ipRegex)
    foreach ($match in $matches) {
        $ipList += $match.Value
    }
}

$ipList | Sort-Object | Get-Unique | Tee-Object -FilePath $outputFile
Write-Host "Saved parsed IPs to: $outputFile"
