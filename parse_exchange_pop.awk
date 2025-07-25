#!/usr/bin/awk -f
# Extract IPs from Exchange POP logs
# Default path: C:\Program Files\Microsoft\Exchange Server\V15\Logging\POP3\
# Usage: awk -f parse_exchange_pop.awk *.log | sort | uniq > ParsedIPs-POP.txt


{
    while (match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) {
        print substr($0, RSTART, RLENGTH)
        $0 = substr($0, RSTART + RLENGTH)
    }
}
