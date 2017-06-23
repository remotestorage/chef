name             'remotestorage-redis'
maintainer       'remoteStorage'
maintainer_email 'ops@5apps.com'
license          'All rights reserved'
description      'redis wrapper cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'redisio'
depends 'backup'
