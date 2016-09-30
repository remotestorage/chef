#
# Cookbook Name:: remotestorage-base
# Recipe:: firewall
#
# Copyright 2015, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

# enable default firewall
firewall 'default'

firewall_rule 'ssh' do
  port     22
  protocol :tcp
  command  :allow
end

firewall_rule 'mosh' do
  port     60000..61000
  protocol :udp
  command  :allow
end
