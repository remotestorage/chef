#
# Cookbook Name:: discourse
# Recipe:: nginx
#
# Copyright 2017, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

discourse_path = node["discourse"]["directory"]
server_name   = node["discourse"]["server_name"]

include_recipe "remotestorage-nginx"

directory "/var/www/discourse/.well-known/acme-challenge" do
  owner     node["nginx"]["user"]
  group     node["nginx"]["group"]
  recursive true
  action    :create
end

template "#{node['nginx']['dir']}/sites-available/discourse" do
  source 'nginx_conf_discourse.erb'
  owner 'www-data'
  mode 0640
  variables puma_port:               node["discourse"]["puma_port"],
            server_name:             server_name,
            ssl_cert:                "/etc/letsencrypt/live/#{server_name}/fullchain.pem",
            ssl_key:                 "/etc/letsencrypt/live/#{server_name}/privkey.pem",
            discourse_path:          discourse_path
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site 'discourse' do
  enable true
end

unless node.chef_environment == "development"
  include_recipe "remotestorage-base::letsencrypt"
  # execute "letsencrypt cert for #{server_name}" do
  #   command "./certbot-auto certonly --webroot --agree-tos --email ops@5apps.com --webroot-path /var/www/discourse -d #{server_name} -n"
  #   cwd "/usr/local/certbot"
  #   not_if { File.exist? "/etc/letsencrypt/live/#{server_name}/fullchain.pem" }
  #   notifies :create, "template[#{node['nginx']['dir']}/sites-available/discourse]", :immediately
  # end
end
