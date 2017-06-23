#
# Cookbook:: timezone_iii
# Attribute:: default
#
# Copyright:: 2017, Corey Hemminger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Use universal time if no other timezone is specified
default['timezone_iii']['timezone'] = value_for_platform_family(
  debian: 'Etc/UTC',
  default: 'UTC'
)

# Path to tzdata directory
default['timezone_iii']['tzdata_dir'] = '/usr/share/zoneinfo'

# Path to file used by kernel for local timezone's data
default['timezone_iii']['localtime_path'] = '/etc/localtime'

# Whether to use a symlink to tzdata (instead of copying).
# Used only in the linux-default recipe.
default['timezone_iii']['use_symlink'] = false
