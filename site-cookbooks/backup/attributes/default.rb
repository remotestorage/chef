# Directory where backup config and models are stored
set_unless["backup"]["dir"] = "/usr/local/lib/backup"

# Use default backup model?
set_unless["backup"]["default_model"] = true

# Compression default settings
set_unless["backup"]["compression"]["best"] = true
set_unless["backup"]["compression"]["fast"] = false

default['backup']['user'] = 'backup'

# Archive default settings
set_unless["backup"]["archives"] = {}

# MongoDB default settings
if node["mongodb"]
  set_unless["backup"]["mongodb"]["databases"] = []
  set_unless["backup"]["mongodb"]["host"]      = "localhost"
  set_unless["backup"]["mongodb"]["ipv6"]      = false
  set_unless["backup"]["mongodb"]["lock"]      = false
end

# MySQL default settings
set_unless["backup"]["mysql"]["databases"] = []
set_unless["backup"]["mysql"]["username"]  = "root"
set_unless["backup"]["mysql"]["host"]      = "localhost"

# Redis default settings
set_unless["backup"]["redis"]["databases"]   = []
set_unless["backup"]["redis"]["host"]        = "localhost"
set_unless["backup"]["redis"]["invoke_save"] = false
set_unless["backup"]["redis"]["dump_dir"]    = "/var/lib/redis"

default['backup']['orbit']['keep'] = 10
default['backup']['cron']['hour'] = "05"
default['backup']['cron']['minute'] = "7"

default['backup']['s3']['keep'] = 15
default['backup']['s3']['bucket'] = "remotestorage-backups"
