#
# Cookbook Name:: remotestorage-base
# Recipe:: default
#
# Copyright 2015, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'timezone-ii'

node.override['omnibus_updater']['version']              = '12.13.37'
node.override['omnibus_updater']['kill_chef_on_upgrade'] = false
include_recipe 'omnibus_updater'

package 'mailutils'
node.override['unattended-upgrades']['admin_email'] = 'ops@5apps.com'
include_recipe 'unattended-upgrades'

include_recipe 'apt'
apt_repository 'brightbox_ruby' do
  uri 'http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6'
  notifies :run, 'execute[apt-get update]', :immediately
end

apt_package 'ruby-switch'

["libruby2.2", "ruby2.2-dev", "build-essential", "libssl-dev", "zlib1g-dev"].each do |pkg|
  apt_package pkg do
    action :install
  end
end

apt_package "ruby2.2" do
  action :install
  notifies :run, 'execute[set default ruby]', :immediately
end

execute 'set default ruby' do
  command "ruby-switch --set ruby2.2"
  action :nothing
  notifies :reload, 'ohai[reload]', :immediately
end

package 'mosh'

include_recipe 'users::sysadmins'

node.override['authorization']['sudo']['passwordless'] = true
include_recipe 'sudo'

include_recipe 'postfix'

node.override['set_fqdn'] = '*'
include_recipe 'hostname'

include_recipe 'remotestorage-base::firewall'

package 'ca-certificates'

directory '/usr/local/share/ca-certificates/cacert' do
  action :create
end

['http://www.cacert.org/certs/root.crt', 'http://www.cacert.org/certs/class3.crt'].each do |cert|
  remote_file "/usr/local/share/ca-certificates/cacert/#{File.basename(cert)}" do
    source cert
    action :create_if_missing
    notifies :run, 'execute[update-ca-certificates]', :immediately
  end
end

execute 'update-ca-certificates' do
  action :nothing
end

package "htop"
