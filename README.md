# gandi-ddns-update

## gandi-update-record
### Description
This is a script that gets the current external IP of your router then connects to the Gandi LiveDNS API and either :
   - **updates** your subdomain DNS record with your current IP if necessary
   - or **create** a new A record with your current IP if the given subdomain doesn't exist in zone

If no entry found for the subdomain, a new A record will be added.

### Usage
- **Update or create** : `gandi-update-record subdomain.example.com` 

## gandi-list-records
### Description
This script that list all DNS records managed by Gandi
If subdomain is given in arg[1], only that record will be listed

### Usage
- **List all records in zone** : `gandi-list-records example.com`
- **List subdomain record** : `gandi-list-records subdomain.example.com`


## Howto generate your Gandi API key
https://account.gandi.net/en (login required) Click on `Security`

## API v5 LiveDNS documentation
https://api.gandi.net/docs/livedns/
