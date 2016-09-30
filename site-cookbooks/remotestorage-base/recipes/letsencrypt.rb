#
# Cookbook Name:: remotestorage-base
# Recipe:: letsencrypt
#
# Copyright 2016, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

include_recipe "git"

git "/usr/local/certbot" do
  repository "https://github.com/certbot/certbot"
  action     :sync
  revision   "v0.8.1"
  user       "root"
  group      "root"
end

cron "renew Let's Encrypt certificates" do
  minute "*"
  hour "4"
  command "/usr/local/certbot/certbot-auto renew && service nginx reload"
end
