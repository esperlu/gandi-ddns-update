# gandi-ddns-update

### Description
This is a script that gets the current external IP of your router then connects to the Gandi LiveDNS API and either :
  - **updates** your subdomain DNS record with your current IP when it has changed. necessary ( -u option ). If the DNS record doesn't exist, it will be created.
  - or **delete** the DNS record for your subdomain ( -d option )

If no entry found for the subdomain, a new A record will be added.

### Usage
- **Update or create** : `gandi-ddns.sh -u subdomain.domain` 
- **Delete** : `gandi-ddns.sh -d subdomain.domain`


### Howto generate yourGandi LiveDNS API key
https://account.gandi.net/en (login required)

Click on `Security`

### API v5 documentation
https://api.gandi.net/docs/livedns/
