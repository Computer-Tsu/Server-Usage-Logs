#!/usr/bin/awk -f
# Extract IPs from Exchange IMAP logs
# Default: C:\Program Files\Microsoft\Exchange Server\V15\Logging\IMAP4\
# Usage: awk -f parse_exchange_imap.awk *.log | sort | uniq > ParsedIPs-IMAP.txt


{
    while (match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) {
        print substr($0, RSTART, RLENGTH)
        $0 = substr($0, RSTART + RLENGTH)
    }
}
