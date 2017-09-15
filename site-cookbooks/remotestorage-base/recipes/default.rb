#
# Cookbook Name:: remotestorage-base
# Recipe:: default
#
# Copyright 2015, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

node.override['apt']['compile_time_update'] = true
include_recipe 'apt'
include_recipe 'timezone_iii'
include_recipe 'ntp'

package 'mailutils'

unless node.chef_environment == "development"
  # Update chef to the chosen version
  chef_version = '12.21.3'
  chef_client_updater "Install #{chef_version}" do
    version chef_version
  end

  node.override['unattended-upgrades']['admin_email'] = 'ops@5apps.com'
  include_recipe 'unattended-upgrades'

  package 'mosh'

  # Searches data bag "users" for groups attribute "sysadmin".
  # Places returned users in Unix group "sysadmin" with GID 2300.
  users_manage 'sysadmin' do
    group_id 2300
    action [:remove, :create]
  end

  node.override['authorization']['sudo']['sudoers_defaults'] = [
    # not default on Ubuntu, explicitely enable. Uses a minimal white list of
    # environment variables
    'env_reset',
    # Send emails on unauthorized attempts
    'mail_badpass',
    'secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"',
  ]
  node.override['authorization']['sudo']['passwordless'] = true
  include_recipe 'sudo'

  include_recipe 'remotestorage-base::firewall'

  node.override['set_fqdn'] = '*'
  include_recipe 'hostname'
end

include_recipe 'remotestorage-postfix'

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
