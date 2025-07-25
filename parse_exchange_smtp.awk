#!/usr/bin/awk -f
# This script parses Exchange SMTP logs to extract client IPs
# Example: awk -f parse_exchange_smtp.awk *.log | sort | uniq > ParsedIPs-ExchangeSMTP.txt


BEGIN {
    FS=" "
    client_ip_index = -1
}

# Parse the Fields line to locate client-ip column
/^#Fields:/ {
    for (i = 1; i <= NF; i++) {
        if ($i == "client-ip") {
            client_ip_index = i
        }
    }
    next
}

# Skip other comment lines
/^#/ { next }

# Extract and print the client-ip field
{
    if (client_ip_index > 0 && client_ip_index <= NF) {
        print $client_ip_index
    }
}
