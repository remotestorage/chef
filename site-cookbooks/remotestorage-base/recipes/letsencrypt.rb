#
# Cookbook Name:: remotestorage-base
# Recipe:: letsencrypt
#
# Copyright 2016, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

git "/usr/local/certbot" do
  repository "https://github.com/certbot/certbot"
  action     :sync
  revision   "v0.15.0"
  user       "root"
  group      "root"
end

letsencrypt_renew_hook = <<-EOF
#!/usr/bin/env bash

# Reloading nginx is enough to read the new certificates
systemctl reload nginx
EOF

file "/usr/local/bin/letsencrypt_renew_hook" do
  content letsencrypt_renew_hook
  mode 0700
  owner "root"
  group "root"
end

cron "renew Let's Encrypt certificates" do
  minute "0"
  hour "4"
  # The post hook is only executed if a cert has been renewed
  command "/usr/local/certbot/certbot-auto renew --renew-hook \"/usr/local/bin/letsencrypt_renew_hook\" -n"
end
