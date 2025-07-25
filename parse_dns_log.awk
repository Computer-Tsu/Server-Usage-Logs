#!/usr/bin/awk -f
# AWK script for extracting IPs from DNS debug log
# Usage: awk -f parse_dns_log.awk dns.log | sort | uniq > ParsedIPs-DNS.txt
Example: awk -f parse_dns_log.awk /mnt/c/Windows/System32/dns/dns.log | sort | uniq > ParsedIPs-DNS.txt


{
    # Find and extract IPs
    while (match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) {
        print substr($0, RSTART, RLENGTH)
        $0 = substr($0, RSTART + RLENGTH)
    }
}
