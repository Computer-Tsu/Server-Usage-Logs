#!/usr/bin/awk -f
# Extract domain names requested in DNS debug logs
# Usage: awk -f parse_dns_queries.awk /mnt/c/Windows/System32/dns/dns.log | sort | uniq > ParsedNames-DNS.txt


# This regex matches domain names like www.example.com or sub.domain.co.uk
# It excludes IP addresses and focuses on alphabetic domains

{
    # Only process lines that likely represent DNS queries
    if ($0 ~ /Query for|received name query|QRY/) {
        # Loop to match multiple domain names in a line
        while (match($0, /([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}/)) {
            domain = substr($0, RSTART, RLENGTH)
            print tolower(domain)
            # Remove the matched part from the line to continue finding others
            $0 = substr($0, RSTART + RLENGTH)
        }
    }
}
