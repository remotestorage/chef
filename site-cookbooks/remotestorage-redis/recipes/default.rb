#
# Cookbook Name:: remotestorage-redis
# Recipe:: default
#
# Copyright 2017, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

node.override['redisio']['version'] = '3.2.9'
include_recipe 'redisio'
include_recipe 'redisio::enable'

unless node.chef_environment == "development"
  # Backup the database to S3
  node.override["backup"]["redis"]["databases"] = ["dump"]
  include_recipe "backup"
end
