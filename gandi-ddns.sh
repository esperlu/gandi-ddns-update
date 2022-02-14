# This is a script that gets the current external IP of your router then connects to the Gandi
# LiveDNS API and either 
#   - updates your subdomain DNS record with your current IP if necessary (-u option )
#   - or delete the DNS A record for your subdomain (-d option )
# If no entry found for the subdomain, a new A record will be added.

# First get a Gandi LiveDNS API key: https://account.gandi.net/en (login required)
# Gandi LiveDNS API key
API_KEY="your API key"

# Test args
if [ "$1" != "-u" ] && [ "$1" != "-d" ] || [ $# -ne 2 ]; then
    printf "\nUsage UPDATE : ${0#*/} -u subdomain.domain \nUsage DELETE : ${0#*/} -d subdomain.domain\n\n"
    exit
fi

# Gandi LiveDNS API KEY
API_KEY="your API key"

# Get subdomain and domain names from args
SUBDOMAIN=${2%%.*}
DOMAIN=${2#*.}

# Delete record (option -d)
if [ "$1" = "-d" ]; then
    RESPONSE=$(curl -s --request DELETE -H "Authorization: Apikey $API_KEY" "https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/$SUBDOMAIN/A" \
    | jq -r ".message" )
    if [ "$RESPONSE" = "" ]; then
        echo "DNS Record for $SUBDOMAIN.$DOMAIN deleted"
    else
        echo $RESPONSE
    fi
    exit
fi

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
| jq -r '.message'
