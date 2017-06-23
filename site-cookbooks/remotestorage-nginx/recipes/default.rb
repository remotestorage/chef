#
# Cookbook Name:: remotestorage-nginx
# Recipe:: default
#
# Copyright 2015, remoteStorage
#
# All rights reserved - Do Not Redistribute
#
node.override['nginx']['default_site_enabled'] = false
node.override['nginx']['server_tokens']        = 'off'
node.override['nginx']['log_formats']['json']  = <<-EOF
'{"ip":"$remote_addr",'
'"time":"$time_local",'
'"host":"$host",'
'"method":"$request_method",'
'"uri":"$uri",'
'"status":$status,'
'"size":$body_bytes_sent,'
'"referer":"$http_referer",'
'"upstream_addr":"$upstream_addr",'
'"upstream_response_time":"$upstream_response_time",'
'"ua":"$http_user_agent"}'
EOF


include_recipe 'chef_nginx'
include_recipe 'remotestorage-base::firewall'

firewall_rule 'http/https' do
  port     [80, 443]
  protocol :tcp
  command  :allow
end
