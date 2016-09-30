name 'wiki'
description 'set up mediawiki'

run_list %w(
  recipe[remotestorage-mediawiki]
)
