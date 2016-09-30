# WARNING! DO NOT RUN THIS ON THE CURRENT SERVER

This is a completely new repo, I will create a new server and import the
current DB. A "Floating IP" has been attached to the current server. This will
allow to switch over without downtime once the DNS entry has been updated.


### Install dependencies (Ruby gems, requires Ruby)

    ./script/bootstrap


### Get the encrypted_data_bag_secret file, copy it to `.chef`


### Run Chef Solo

    knife solo cook root@IP


### Bootstrap the new server

    knife solo prepare root@IP
