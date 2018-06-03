

## TODO
- [ ] Create Apache2 vhost automatically
    - [ ] Create vhost config file in /etc/apache2/sites-available
    - [ ] Map hostname by appending the name into /etc/hosts
- [ ] Create nginx config file automatically
- [ ] 

## Types
- [ ] Single network, single host
- [ ] Single network, multiple vhosts
- [ ] Multiple networks expose to nginx which exposes to public

## Docker Manager (dm)
- [ ] dm compose delete <compose-name>
- [x] Check duplicate compose name before building
- [ ] If compose up multiple project, apache will use the same port. Use nginx as a single proxy which connect the internet with all compose networks.
- [ ] Try using env variables for default version of php and mysql instead of hardcode it.