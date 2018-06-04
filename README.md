

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

## Stack
- [x] Apache2
- [x] PHP-FPM
- [ ] NGINX
- [x] MySQL
- [ ] MariaDB
- [ ] OpenSSL
- [ ] MemCached
- [ ] Redis

## Containers configs
- PHP-FPM
    

## Apps setup
- WordPress
    - Login as www-data
    - Download location
    - WordPress version
    - Database name, username, password, host
    - Admin name, password, email
    - plugins
    - themes
    - Data import

## Docker Manager (dm)
- [x] list all project
- [ ] dm compose delete <compose-name>; delete when compose is running?
- [x] Check duplicate compose name before building
- [ ] If compose up multiple project, apache will use the same port. Use nginx as a single proxy which connect the internet with all compose networks.
- [ ] Try using env variables for default version of php and mysql instead of hardcode it.
- [ ] Able to create custom docker-compose.yml template

## Issues
- [ ] Duplicate compose project name when using `dm compose build <name> --override`