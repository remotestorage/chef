#
# Cookbook Name:: mediawiki
# Recipe:: nginx
#

node.set_unless['php-fpm']['pools'] = []

include_recipe "php-fpm"
include_recipe 'php-fpm::repository' unless node['php-fpm']['skip_repository_install']
include_recipe "php-fpm::install"

php_fpm_pool "www" do
  enable false
end

php_fpm_pool "mediawiki" do
  listen "127.0.0.1:9002"
  user node['nginx']['user']
  group node['nginx']['group']
  listen_owner node['nginx']['user']
  listen_group node['nginx']['group']
  php_options node['mediawiki']['php_options']
  start_servers 5
  enable true
end

include_recipe "php::module_mysql"
include_recipe "chef_nginx"

directory node["mediawiki"]["docroot_dir"] do
  user node['nginx']['user']
  group node['nginx']['group']
  recursive true
end
