<#
.SYNOPSIS
    Parses Exchange SMTPReceive logs to extract unique client IPs.

.DESCRIPTION
    - Scans SMTP protocol logs for 'client-ip' values.
    - Supports CSV or plain-text output.
    - Displays optional progress indicator.

.PARAMETER LogFolder
    Path to the SMTPReceive log folder

.PARAMETER Csv
    Output IP counts as CSV file sorted by frequency

.PARAMETER NoProgress
    Disables progress bar for speed

.EXAMPLE
    .\Parse-ExchangeSMTPLogs.ps1 -Csv
#>

param (
    [string]$LogFolder = "C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive\",
    [switch]$Csv,
    [switch]$NoProgress
)

Write-Host "Parsing Exchange SMTP logs from folder: $LogFolder"

if (-Not (Test-Path $LogFolder)) {
    Write-Warning "Exchange SMTP log folder not found: $LogFolder"
    Write-Host "To enable logging:"
    Write-Host "1. Open Exchange Admin Center or EMS"
    Write-Host "2. Protocol logging should be enabled for Receive/Send connectors"
    exit 1
}

$outputCsv = "ParsedIPs-ExchangeSMTP.csv"
$outputTxt = "ParsedIPs-ExchangeSMTP.txt"
$ipCount = @{}
$files = Get-ChildItem -Path $LogFolder -Filter *.log
$total = $files.Count
$count = 0

foreach ($file in $files) {
    $count++
    if (-not $NoProgress -and ($count % 1 -eq 0)) {
        Write-Progress -Activity "Parsing SMTP Logs" -Status "$count of $total files" -PercentComplete (($count / $total) * 100)
    }

    $clientIpIndex = -1
    $headerParsed = $false

    Get-Content $file.FullName | ForEach-Object {
        if ($_ -like "#Fields:*" -and -not $headerParsed) {
            $fields = ($_ -replace "^#Fields:\s*", "") -split "\s+"
            $clientIpIndex = $fields.IndexOf("client-ip")
            $headerParsed = $true
            return
        }

        if ($_ -like "#*") { return }

        if ($clientIpIndex -ge 0) {
            $cols = $_ -split "\s+"
            if ($cols.Length -gt $clientIpIndex) {
                $ip = $cols[$clientIpIndex]
                if ($ip -match '^\d{1,3}(\.\d{1,3}){3}$') {
                    if ($ipCount.ContainsKey($ip)) { $ipCount[$ip]++ }
                    else { $ipCount[$ip] = 1 }
                }
            }
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
