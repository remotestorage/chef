name             'remotestorage-mediawiki'
maintainer       'remoteStorage'
maintainer_email 'mail@remotestorage.io'
license          'All rights reserved'
description      'Installs/Configures remotestorage-mediawiki'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "remotestorage-nginx"
depends "mediawiki"
depends "firewall"
depends "ark"
depends "backup"
depends "remotestorage-base"
