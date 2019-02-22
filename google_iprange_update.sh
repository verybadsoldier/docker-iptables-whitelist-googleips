#!/usr/bin/env bash

IPSET_NAME_TMP="${IPSET_NAME}_TMP"
IPTABLES_COMMENT="Check for Google IP"

ipset -! -q create "$IPSET_NAME" nethash

iptables -n --list "$CHAIN_NAME" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    iptables -F "$CHAIN_NAME"
else
    iptables -N "$CHAIN_NAME" 2> /dev/null
fi

iptables -A "$CHAIN_NAME" -m set ! --match-set "$IPSET_NAME" src -j DROP

cur_rules=$(iptables-save | grep -e "--comment \"$IPTABLES_COMMENT\"")
IFS=$'\n'
for i in $cur_rules; do
    i="${i:3}"
    i=($i)
    iptables -D ${i[@]}
done
unset IFS

for i in $TARGET_CHAINS; do
    iptables -I "$i" -p tcp -m tcp --dport $TCP_PORT -j "$CHAIN_NAME" -m comment --comment "$IPTABLES_COMMENT"
done

ipset -! -q destroy "$IPSET_NAME_TMP"
ipset create "$IPSET_NAME_TMP" nethash

subdomains="_netblocks _netblocks3"
while :
do
    # _netblocks2 is ipv6
    for subdomain in $subdomains
    do
        response=$(nslookup -q=TXT $subdomain.google.com 8.8.8.8)
        ips=$(echo "$response" | egrep -o '\<ip[46]:[^ ]+' | cut -c 5-)

        for ip in $ips
        do
          ipset add "$IPSET_NAME_TMP" "$ip"
        done
    done

    ipset swap "$IPSET_NAME" "$IPSET_NAME_TMP"
    ipset destroy "$IPSET_NAME_TMP"

    sleep $((($RANDOM % 20 + 50) * 10)) # sleeps for about 10 minutes (add random variable to avoid DDoS)
done
