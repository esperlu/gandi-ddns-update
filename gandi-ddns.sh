#!/usr/bin/bash

# gandi-ddns

# This is a script that gets the current external IP of your router then connects to the Gandi
# LiveDNS API and updates your subdomain DNS record with your current IP if necessary.
# If no entry found for the subdomain, a new A record will be added.

# Gandi LiveDNS API KEY
API_KEY="Your API key"

# Domain hosted with Gandi
DOMAIN="your domain"

# Subdomain to update DNS
SUBDOMAIN="your subdomain"

# Get external IP address
EXT_IP=$(curl -s ifconfig.me)  
echo "External IP : " $EXT_IP

# Get the current Zone for the provided domain
CURRENT_ZONE_HREF=$(curl -s -H "X-Api-Key: $API_KEY" https://dns.api.gandi.net/api/v5/domains/$DOMAIN \
| jq -r '.zone_records_href')

# Get current current IP found in DNS A records
CURRENT_IP_IN_ZONE=$(curl -s -H "X-Api-Key: $API_KEY" "https://dns.api.gandi.net/api/v5/domains/$DOMAIN/records" \
| jq -r ".[] | select(.rrset_name == \"$SUBDOMAIN\") | .rrset_values[0]")

if [ "$CURRENT_IP_IN_ZONE" = "" ]; then
    echo "IP in DNS ZONE : No DNS record found. Creating one..."
else
    echo "IP in DNS ZONE : " $CURRENT_IP_IN_ZONE
fi

# If IP's are the same, nothing to do and exit
if [ "$CURRENT_IP_IN_ZONE" = "$EXT_IP" ]; then
    echo "No change. Exiting..."
    exit
fi

# Update the A Record of the subdomain using PUT
curl -s \
--url "$CURRENT_ZONE_HREF/$SUBDOMAIN/A" \
--request PUT \
--header "Content-Type: application/json" \
--header "X-Api-Key: $API_KEY" \
--data '{
            "rrset_name": "'$SUBDOMAIN'",
            "rrset_type": "A",
            "rrset_ttl": 1200,
            "rrset_values": ["'$EXT_IP'"]
        }' \
| jq -r
