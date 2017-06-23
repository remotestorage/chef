# WARNING! DO NOT RUN THIS ON THE CURRENT SERVER

This is a completely new repo, I will create a new server and import the
current DB. A "Floating IP" has been attached to the current server. This will
allow to switch over without downtime once the DNS entry has been updated.

This repo works on Ubuntu 16.04, it has been tested with it on Vagrant (and the
mediawiki recipe has been tested on a temporary server on Digital Ocean)

### Install dependencies (Ruby gems, requires Ruby)

    ./script/bootstrap


### Get the encrypted_data_bag_secret file, copy it to `.chef`


### Run Chef Solo

    knife solo cook root@IP


### Bootstrap the new server

    knife digital_ocean droplet create --server-name web.remotestorage.io \
                                       --image ubuntu-16-04-x64 \
                                       --location fra1 \
                                       --size 1gb \
                                       --ssh-keys 11577,1536005 \
                                       --run-list "role[mediawiki],role[discourse]" \
                                       --secret-file ".chef/encrypted_data_bag_secret" \
                                       --solo
