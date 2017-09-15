name             'remotestorage-base'
maintainer       'remoteStorage'
maintainer_email 'mail@remotestorage.io'
license          'All rights reserved'
description      'The remoteStorage base cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

depends 'unattended-upgrades'
depends 'users'
depends 'sudo'
depends 'remotestorage-postfix'
depends 'hostname'
depends 'firewall'
depends 'chef_client_updater'
depends 'timezone_iii'
depends 'ntp'
depends 'apt'
