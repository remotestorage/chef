# Mediawiki

## Restore backup

mysql -u mediawikiuser -D mediawiki < /path/to/mediawiki.sql
cd /var/www/mediawiki-1.29.1/maintenance; php update.php --quick
