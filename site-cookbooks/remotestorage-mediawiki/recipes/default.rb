#
# Cookbook Name:: remotestorage-mediawiki
# Recipe:: default
#
# Copyright 2016, remoteStorage
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
include_recipe 'ark'

node.override['mediawiki']['version']         = "1.27.1"
node.override['mediawiki']['webdir']          = "#{node["mediawiki"]["docroot_dir"]}/mediawiki-#{node['mediawiki']['version']}"
node.override['mediawiki']['tarball']['name'] = "mediawiki-#{node['mediawiki']['version']}.tar.gz"
node.override['mediawiki']['tarball']['url']  = "https://releases.wikimedia.org/mediawiki/1.27/#{node['mediawiki']['tarball']['name']}"
node.override['mediawiki']['language_code']   = 'en'
node.override['mediawiki']['server_name']     = 'wiki.remotestorage.io'
node.override['mediawiki']['site_name']       = 'remotestorage Wiki'
node.override['mediawiki']['server']          = "https://#{node['mediawiki']['server_name']}"

mysql_credentials = Chef::EncryptedDataBagItem.load('credentials', 'mysql')
mediawiki_credentials = Chef::EncryptedDataBagItem.load('credentials', 'mediawiki')

node.override['mediawiki']['db']['root_password'] = mysql_credentials["root_password"]
node.override['mediawiki']['db']['pass'] = mediawiki_credentials["db_pass"]

# Fix bug in php cookbook
if platform?('ubuntu') && node[:platform_version].to_f == 14.04
  node.override['php']['ext_conf_dir']          = '/etc/php5/mods-available'
end

directory "#{node['mediawiki']['webdir']}/skins/common/images" do
  owner node['nginx']['user']
  group node['nginx']['group']
  recursive true
  mode 0750
end

# Overwrite the default theme with our custom theme

cookbook_file "#{node['mediawiki']['webdir']}/skins/Vector.tar.gz" do
  source 'Vector.tar.gz'
  owner node['nginx']['user']
  group node['nginx']['group']
  mode 0640
end

execute "install skin" do
  command 'tar xfz Vector.tar.gz'
  cwd "#{node['mediawiki']['webdir']}/skins"
  subscribes :run, "cookbook_file[#{node['mediawiki']['webdir']}/skins/Vector.tar.gz]"
  action :nothing
end

include_recipe "mediawiki"
include_recipe "remotestorage-nginx"
include_recipe "mediawiki::nginx"
include_recipe "remotestorage-base::letsencrypt"

execute "letsencrypt cert for wiki.remotestorage.io" do
  command "./certbot-auto certonly --webroot --agree-tos --email ops@5apps.com --webroot-path #{node["mediawiki"]["docroot_dir"]} -d wiki.remotestorage.io"
  cwd "/usr/local/certbot"
  not_if { File.exist? "/etc/letsencrypt/live/wiki.remotestorage.io/fullchain.pem" }
  notifies :reload, "service[nginx]", :delayed
end

template "#{node['nginx']['dir']}/sites-available/mediawiki" do
  source "nginx.conf.erb"
  variables(
    docroot:        node['mediawiki']['webdir'],
    server_name:    node['mediawiki']['server_name'],
    ssl_cert:       "/etc/letsencrypt/live/wiki.remotestorage.io/fullchain.pem",
    ssl_key:        "/etc/letsencrypt/live/wiki.remotestorage.io/privkey.pem"
  )
  action :create
  notifies :reload, "service[nginx]", :delayed
end

nginx_site 'mediawiki' do
  enable true
end

# Extensions

mediawiki_credentials = Chef::EncryptedDataBagItem.load('credentials', 'mediawiki')

ark "antispam" do
  url "https://github.com/CleanTalk/mediawiki-antispam/archive/1.7.zip"
  path "#{node['mediawiki']['webdir']}/extensions/Antispam"
  owner node["nginx"]["user"]
  group node["nginx"]["group"]
  mode 0750
  action :dump
end

# MediawikiHubot extension
# requires curl extension
package "php5-curl"

ark "MediawikiHubot" do
  url "https://github.com/67P/mediawiki-hubot/archive/master.zip"
  path "#{node['mediawiki']['webdir']}/extensions/MediawikiHubot"
  creates "MediawikiHubot/MediawikiHubot.php"
  action :cherry_pick
end

hal8000_freenode_data_bag_item = Chef::EncryptedDataBagItem.load('credentials', 'hal8000_freenode')
webhook_token = hal8000_freenode_data_bag_item['webhook_token']

template "#{node['mediawiki']['webdir']}/extensions/MediawikiHubot/DefaultConfig.php" do
  source "MediawikiHubot/DefaultConfig.php.erb"
  variables webhook_url: "http://dev.kosmos.org:8080/incoming/#{webhook_token}",
            room_name: "#remotestorage",
            wiki_url: "https://wiki.remotestorage.io/"
end

ruby_block "configuration" do
  block do
    file = Chef::Util::FileEdit.new("#{node['mediawiki']['webdir']}/LocalSettings.php")
    # file.search_file_replace_line(/\$wgLogo\ =\ \"\$wgResourceBasePath\/resources\/assets\/wiki.png\";/,
    #                               "$wgLogo = \"$wgResourceBasePath/skins/common/images/remotestorage.png\";")
    file.insert_line_if_no_match(/# Our config/,
                                 <<-EOF
# Our config
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['team'] = $wgGroupPermissions['user'];
$wgGroupPermissions['user'   ]['edit']       = false;
$wgGroupPermissions['user']['editsemiprotected'] = false;
$wgGroupPermissions['autoconfirmed']['editsemiprotected'] = false;
$wgGroupPermissions['team']['edit']          = true;
$wgGroupPermissions['team']['protect']  = true;
$wgGroupPermissions['team']['editsemiprotected']  = true;
$wgGroupPermissions['team']['editprotected']  = true;
$wgGroupPermissions['sysop']['edit'] = true;
$wgEnableUploads = true;

$wgExtraNamespaces[100] = "Feature";
$wgNamespacesWithSubpages[100] = true;
$wgExtraNamespaces[101] = "Feature_Talk";
# Only allow sysops to edit "Feature" namespace
$wgGroupPermissions['team']['editfeature'] = true;
$wgGroupPermissions['sysop']['editfeature'] = true;
$wgNamespaceProtection[100] = array( 'editfeature' );
$wgSMTP = array (
   'IDHost' => 'remotestorage.io', //this is used to build the Message-ID mail header
   'host'   => 'localhost', //this is the outgoing mail server name (SMTP server)
   'port'   => 25, //this is the port used by the SMTP server
   'auth'   => false,  //in my case, authentication is not required by the mail server for outgoing mail
);
$wgPasswordReminderResendTime = 0;
$wgArticlePath = "/$1";
                                 EOF
                                )
    file.insert_line_if_no_match(/Antispam\.php/,
                                 "require_once \"$IP/extensions/Antispam/Antispam.php\";")
    file.insert_line_if_no_match(/wgCTAccessKey/,
                                 "$wgCTAccessKey = \"#{mediawiki_credentials['antispam_key']}\";")
    file.insert_line_if_no_match(/MediawikiHubot\.php/,
                                 "require_once \"$IP/extensions/MediawikiHubot/MediawikiHubot.php\";")
    file.write_file
  end
end

node.override["backup"]["mysql"]["host"] = "localhost"
node.override["backup"]["mysql"]["username"] = "root"
node.override["backup"]["mysql"]["password"] = node["mediawiki"]["db"]["root_password"]
unless node["backup"]["mysql"]["databases"].include? 'mediawikidb'
  node.override["backup"]["mysql"]["databases"] =
    node["backup"]["mysql"]["databases"].to_a << "mediawikidb"
end

include_recipe "backup"
