name 'base'
description 'base cookbook'

run_list %w(
  recipe[remotestorage-base]
)
