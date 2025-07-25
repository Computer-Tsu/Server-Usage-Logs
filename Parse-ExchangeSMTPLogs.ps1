<#
.SYNOPSIS
    Parses Exchange SMTPReceive logs to extract unique client IP addresses.

.DESCRIPTION
    - Reads *.log files in the default or specified Exchange SMTP protocol log folder.
    - Skips comment lines.
    - Extracts the client-ip column.
    - Deduplicates and sorts IPs.
    - Saves results to a file in the current working directory.
#>

param (
    [string]$LogFolder = "C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive\"
)

# Print the folder being used
Write-Host "Parsing Exchange SMTP logs from folder: $LogFolder"

# Validate folder
if (-Not (Test-Path $LogFolder)) {
    Write-Error "Specified log folder does not exist: $LogFolder"
    exit 1
}

$outputFile = Join-Path -Path (Get-Location) -ChildPath "ParsedIPs-ExchangeSMTP.txt"
$ipList = @()

# Process each .log file
Get-ChildItem -Path $LogFolder -Filter *.log | ForEach-Object {
    Write-Host "Reading: $($_.FullName)"
    $headerParsed = $false
    $clientIpIndex = -1

    Get-Content $_.FullName | ForEach-Object {
        # Skip empty lines
        if ([string]::IsNullOrWhiteSpace($_)) { return }

        if ($_ -like "#Fields:*" -and -not $headerParsed) {
            # Get the header line and find the index of client-ip
            $fields = ($_ -replace "^#Fields:\s*", "") -split "\s+"
            $clientIpIndex = $fields.IndexOf("client-ip")
            $headerParsed = $true
            return
        }

        if ($_ -like "#*") { return }

        if ($clientIpIndex -ge 0) {
            $cols = $_ -split "\s+"
            if ($cols.Length -gt $clientIpIndex) {
                $ipList += $cols[$clientIpIndex]
            }
        }
    }
}

$ipList | Sort-Object | Get-Unique | Tee-Object -FilePath $outputFile
Write-Host "Saved parsed IPs to: $outputFile"
