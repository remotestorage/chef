#
# Cookbook Name:: remotestorage-ruby
# Recipe:: default
#
# Copyright 2017, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

return unless platform? 'ubuntu'

package_name = "ruby#{node['remotestorage-ruby']['version']}"

apt_repository 'brightbox_ruby' do
  uri 'http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6'
end

packages = [
  "ruby#{node['remotestorage-ruby']['version']}",
  "ruby#{node['remotestorage-ruby']['version']}-dev",
  "build-essential",
  "libssl-dev",
  "zlib1g-dev"
]

apt_package packages do
  action :install
end

apt_package 'ruby-switch' do
  action :install
  notifies :run, 'execute[set default ruby]', :immediately
end

ohai 'reload in remotestorage-ruby::default' do
  action :nothing
end

execute 'set default ruby' do
  command "ruby-switch --set #{package_name}"
  action :nothing
  notifies :reload, 'ohai[reload in remotestorage-ruby::default]', :immediately
end

execute 'update rubygems' do
  command 'gem update --system 2.6.12 --no-document'
  not_if  "gem --version | grep ^2.6.12$"
end

gem_package "bundler" do
  version "1.15.1"
end
