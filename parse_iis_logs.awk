#!/usr/bin/awk -f
# This AWK script extracts client IPs from IIS log files
# Usage: awk -f parse_iis_logs.awk <logfile1> <logfile2> ... > ParsedIPs-IIS.txt
# Example: awk -f parse_iis_logs.awk /mnt/c/inetpub/logs/LogFiles/W3SVC1/u_ex*.log | sort | uniq > ParsedIPs-IIS.txt


# Skip comment lines
/^#/ { next }

# Extract the first column (c-ip)
{
    print $1
}
