name             'remotestorage-base'
maintainer       'remoteStorage'
maintainer_email 'mail@remotestorage.io'
license          'All rights reserved'
description      'The remoteStorage base cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

depends 'unattended-upgrades'
depends 'users'
depends 'chef-solo-search'
depends 'sudo'
depends 'postfix'
depends 'hostname'
depends 'ufw'
depends 'omnibus_updater'
depends 'timezone-ii'
depends 'git'
