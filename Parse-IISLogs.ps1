<#
.SYNOPSIS
    Parses IIS W3C logs for client IP addresses, deduplicates, sorts, and saves output.

.DESCRIPTION
    - Reads *.log files from default or specified IIS log directory.
    - Extracts 'c-ip' (client IP address) column.
    - Deduplicates and sorts IPs.
    - Saves to a file in the current directory named ParsedIPs-IIS.txt
#>

param (
    [string]$LogFolder = "C:\inetpub\logs\LogFiles"
)

# Print the folder being used
Write-Host "Parsing IIS logs from folder: $LogFolder"

# Validate folder
if (-Not (Test-Path $LogFolder)) {
    Write-Error "Specified log folder does not exist: $LogFolder"
    exit 1
}

# Prepare output file
$outputFile = Join-Path -Path (Get-Location) -ChildPath "ParsedIPs-IIS.txt"

# Collect IP addresses
$ipList = @()

# Process each .log file recursively
Get-ChildItem -Path $LogFolder -Recurse -Filter *.log | ForEach-Object {
    Write-Host "Reading: $($_.FullName)"
    Get-Content $_.FullName | ForEach-Object {
        if ($_ -notmatch "^#") {
            # Split line by space and capture the client IP (usually first column)
            $cols = $_ -split '\s+'
            if ($cols.Length -gt 0) {
                $ipList += $cols[0]
            }
        }
    }
}

# Output result
$ipList | Sort-Object | Get-Unique | Tee-Object -FilePath $outputFile
Write-Host "Saved parsed IPs to: $outputFile"
