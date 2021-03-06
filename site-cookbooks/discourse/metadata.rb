name             'discourse'
maintainer       'remoteStorage'
maintainer_email 'mail@remotestorage.io'
license          'All rights reserved'
description      'Installs/Configures discourse'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "remotestorage-nginx"
depends "remotestorage-redis"
depends "remotestorage-base"
depends "remotestorage-ruby"
depends "application_ruby"
depends "postgresql"
depends "database"
depends "backup"
depends "apt"
depends "build-essential"
