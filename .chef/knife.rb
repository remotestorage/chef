current_dir = File.dirname(__FILE__)

cookbook_path             ["#{current_dir}/../cookbooks", "#{current_dir}/../site-cookbooks"]
node_path                 "nodes"
role_path                 "roles"
environment_path          "environments"
data_bag_path             "data_bags"
encrypted_data_bag_secret "#{current_dir}/encrypted_data_bag_secret"
local_mode                true # Chef local mode, replacing Solo

cookbook_copyright     'remoteStorage'
cookbook_license       'none'
cookbook_email         'mail@remotestorage.io'

knife[:bootstrap_version]   = '12.20.3'

knife[:digital_ocean_access_token]  = "#{ENV['DIGITAL_OCEAN_ACCESS_TOKEN']}"
