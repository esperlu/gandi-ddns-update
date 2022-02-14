
# This script get your current external IP of your router then connects to the Gandi
# LiveDNS API and updates your subdomain DNS record with your current IP if necessary.

# Gandi LiveDNS API KEY
API_KEY="your Gandi LiveDNS key"

# Domain hosted with Gandi
DOMAIN="your domain"

# Subdomain to update DNS
SUBDOMAIN="your subdomain"

# Get external IP address
EXT_IP=$(curl -s ifconfig.me)  


#Get the current Zone for the provided domain
CURRENT_ZONE_HREF=$(curl -s -H "X-Api-Key: $API_KEY" https://dns.api.gandi.net/api/v5/domains/$DOMAIN | jq -r '.zone_records_href')
CURRENT_IP_IN_ZONE=$(curl -s -H "X-Api-Key: $API_KEY" "https://dns.api.gandi.net/api/v5/domains/$DOMAIN/records" | jq -r ".[] | select(.rrset_name == \"$SUBDOMAIN\") | .rrset_values[0]")

echo "External IP : " $EXT_IP

if [ "$CURRENT_IP_IN_ZONE" = "" ]; then
    echo "IP in DNS ZONE : None"
else
    echo "IP in DNS ZONE : " $CURRENT_IP_IN_ZONE
fi
if [ "$CURRENT_IP_IN_ZONE" = "$EXT_IP" ]; then
    echo "NO CHANGE"
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
