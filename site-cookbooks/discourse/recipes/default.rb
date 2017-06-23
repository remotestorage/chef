#
# Cookbook Name:: discourse
# Recipe:: default
#
# Copyright 2017, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

include_recipe "remotestorage-redis"
include_recipe "remotestorage-ruby"
node.override['postgresql']['enable_pgdg_apt'] = false
node.override['postgresql']['contrib']['extensions'] = ['hstore', 'pg_trgm']
include_recipe "postgresql::server"
include_recipe "postgresql::contrib"
include_recipe "postgresql::ruby"
unless node.chef_environment == "development"
  node.override['postgresql']['config_pgtune']['db_type'] = "web"
  include_recipe "postgresql::config_pgtune"
end

# discourse_credentials = Chef::EncryptedDataBagItem.load('credentials', 'discourse')

postgresql_connection_info = {
  host:     '127.0.0.1',
  port:     5432,
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

# grant privileges
postgresql_database_user 'discourse' do
  connection    postgresql_connection_info
  database_name 'discourse'
  password      "testpassword"
end

postgresql_database 'discourse' do
  connection postgresql_connection_info
  action :create
end

# grant privileges
postgresql_database_user 'discourse' do
  connection    postgresql_connection_info
  database_name 'discourse'
  schema_name 'public'
  tables        [:all]
  sequences     [:all]
  functions     [:all]
  privileges    [:all]
  action        [:grant, :grant_schema, :grant_table, :grant_sequence, :grant_function]
end

discourse_path = node["discourse"]["directory"]

group "discourse" do
  gid 34726
end

user "discourse" do
  comment "discourse user"
  uid 34726
  gid 34726
  shell "/bin/bash"
  home discourse_path
end

# package %w()

application discourse_path do
  owner "discourse"
  group "discourse"

  environment "HOME" => discourse_path

  git do
    user "discourse"
    group "discourse"
    repository "https://github.com/discourse/discourse"
    revision   "v1.8.1"
  end

  # discourse_credentials = Chef::EncryptedDataBagItem.load('credentials', 'discourse')

  directory "#{discourse_path}/public/.well-known" do
    owner node['nginx']['user']
    group node['nginx']['group']
    recursive true
  end

  bundle_install do
    user "discourse"
    deployment true
    without %w(development test)
  end

  rails do
    migrate true
    rails_env "production"
    precompile_assets false
  end

  execute "systemctl daemon-reload" do
    command "systemctl daemon-reload"
    action :nothing
  end

  # discourse-web service
  #
  template "/lib/systemd/system/discourse-web.service" do
    source "discourse-web.systemd.service.erb"
    variables user: user,
              app_dir: discourse_path,
              port: node["discourse"]["puma_port"],
              bundle_path: "/usr/local/bin/bundle"
    notifies :run, "execute[systemctl daemon-reload]", :delayed
    notifies :restart, "service[discourse-web]", :delayed
  end

  service "discourse-web" do
    action [:enable, :start]
  end

  # discourse-sidekiq service
  #
  template "/lib/systemd/system/discourse-sidekiq.service" do
    source "discourse-sidekiq.systemd.service.erb"
    variables user: user,
              app_dir: discourse_path,
              bundle_path: "/usr/local/bin/bundle"
    notifies :run, "execute[systemctl daemon-reload]", :delayed
    notifies :restart, "service[discourse-sidekiq]", :delayed
  end

  service "discourse-sidekiq" do
    action [:enable, :start]
  end
end

unless node.chef_environment == "development"
  # Backup the database to S3
  node.override["backup"]["postgresql"]["host"]     = "localhost"
  node.override["backup"]["postgresql"]["username"] = "postgres"
  node.override["backup"]["postgresql"]["password"] = node['postgresql']['password']['postgres']
  include_recipe "backup"
end