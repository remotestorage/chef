#
# Cookbook Name:: remotestorage-postfix
# Recipe:: default
#
# Copyright 2016, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

smtp_credentials = Chef::EncryptedDataBagItem.load('credentials', 'smtp')

node.override['postfix']['sasl']['smtp_sasl_user_name']        = smtp_credentials['user_name']
node.override['postfix']['sasl']['smtp_sasl_passwd']           = smtp_credentials['password']
node.override['postfix']['sasl_password_file']                 = "#{node['postfix']['conf_dir']}/sasl_passwd"
# Postfix doesn't support smtps relayhost, use STARTSSL instead
node.override['postfix']['main']['relayhost']                  = smtp_credentials['relayhost']
node.override['postfix']['main']['smtp_sasl_auth_enable']      = 'yes'
node.override['postfix']['main']['smtp_sasl_password_maps']    = "hash:#{node['postfix']['sasl_password_file']}"
node.override['postfix']['main']['smtp_sasl_security_options'] = 'noanonymous'
node.override['postfix']['main']['smtp_tls_CAfile']            = '/etc/ssl/certs/ca-certificates.crt'
node.override['postfix']['main']['smtpd_tls_CAfile']           = '/etc/ssl/certs/ca-certificates.crt'

include_recipe 'postfix::default'
