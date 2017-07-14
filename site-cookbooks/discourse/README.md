# discourse Cookbook

This cookbook installs Discourse (https://discourse.org/)

## Requirements

- Ubuntu

### Chef

- Chef 12.0 or later

## Usage

### discourse::default

Installs discourse

#### Caveat

The confirmation email for the admin account isn't sent. Confirm it in
a Rails console after creating it in the web interface

http://community.remotestorage.io/finish-installation/register

```
sudo su - discourse
RAILS_ENV=production bundle exec rails c
User.last.activate
```

#### Restore a backup

Login with your new admin account
(http://community.remotestorage.io/login).

Go to
http://community.remotestorage.io/admin/site_settings/category/backups?filter=
and check "allow restore"

Go to http://community.remotestorage.io/admin/backups, upload a backup from the
existing forums

Go to http://community.remotestorage.io/admin/site_settings/category/email?filter=
and uncheck "disable emails"

### discourse::nginx

Sets up the nginx vhost
