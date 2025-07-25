#!/usr/bin/awk -f
# This AWK script parses WINS logs and extracts IP addresses
# Usage: awk -f parse_wins_log.awk wins.log | sort | uniq > ParsedIPs-WINS.txt
# Example: awk -f parse_wins_log.awk /mnt/c/Windows/System32/WINS/wins.log | sort | uniq > ParsedIPs-WINS.txt


{
    # Match IPv4 address pattern
    while (match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) {
        print substr($0, RSTART, RLENGTH)
        # Remove the matched IP to find next one in same line
        $0 = substr($0, RSTART + RLENGTH)
    }
}
