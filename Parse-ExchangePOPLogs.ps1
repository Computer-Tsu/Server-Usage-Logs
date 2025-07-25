<#
.SYNOPSIS
    Parses Exchange POP logs to extract unique client IPs with progress bar.

.PARAMETER LogFolder
    Path to Exchange POP log folder.
#>

param (
    [string]$LogFolder = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\POP3\"
)

Write-Host "Parsing Exchange POP logs from folder: $LogFolder"

if (-Not (Test-Path $LogFolder)) {
    Write-Error "Log folder not found: $LogFolder"
    exit 1
}

$outputFile = Join-Path -Path (Get-Location) -ChildPath "ParsedIPs-POP.txt"
$ipRegex = '\b(?:(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\b'
$ipList = @()

$files = Get-ChildItem -Path $LogFolder -Filter *.log
$total = $files.Count
$count = 0

foreach ($file in $files) {
    $count++
    Write-Progress -Activity "Scanning POP logs" -Status "$count of $total" -PercentComplete (($count / $total) * 100)

    Get-Content $file.FullName | ForEach-Object {
        $matches = [regex]::Matches($_, $ipRegex)
        foreach ($match in $matches) {
            $ipList += $match.Value
        }
    }
}

$ipList | Sort-Object | Get-Unique | Tee-Object -FilePath $outputFile
Write-Host "Saved parsed IPs to: $outputFile"
