name             'remotestorage-nginx'
maintainer       'remoteStorage'
maintainer_email 'mail@remotestorage.io'
license          'All rights reserved'
description      'Installs/Configures remotestorage-nginx'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends 'chef_nginx'
depends 'firewall'
depends 'remotestorage-base'
