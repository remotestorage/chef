#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2012, Appcache Ltd / 5apps.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

gem_package 'backup' do
  version '4.2.3'
end

backup_data = Chef::EncryptedDataBagItem.load('credentials', 'backup')

directory node["backup"]["dir"]
directory "#{node["backup"]["dir"]}/models"
directory "#{node["backup"]["dir"]}/log"

template "#{node["backup"]["dir"]}/config.rb" do
  source    "config.rb.erb"
  mode      0640
  sensitive true
  variables s3_access_key_id: backup_data["s3_access_key_id"],
            s3_secret_access_key: backup_data["s3_secret_access_key"],
            s3_region: backup_data["s3_region"],
            encryption_password: backup_data["encryption_password"],
            mail_to: "ops@5apps.com",
            mail_from: "backups@remotestorage.io"
end

if node["backup"]["default_model"]
  template "#{node["backup"]["dir"]}/models/default.rb" do
    source    "backup.rb.erb"
    mode      0640
  end

  cron "default backup model" do
    hour node['backup']['cron']['hour']
    minute node['backup']['cron']['minute']
    command "/usr/bin/env HOME=/home/user PATH=/usr/local/bin:/usr/local/ruby/bin:/usr/bin:/bin:$PATH /bin/sh -l -c 'backup perform -t default --root-path #{node["backup"]["dir"]} >> /var/log/backup.log 2>&1'"
  end

  include_recipe 'logrotate'

  logrotate_app 'backup' do
    path '/var/log/backup.log'
    frequency 'daily'
    rotate 10
    create '640 root root'
  end
end
