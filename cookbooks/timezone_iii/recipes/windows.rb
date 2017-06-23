#
# Cookbook:: timezone_iii
# Recipe:: amazon
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

powershell_script 'set windows timezone' do
  code <<-EOH
  tzutil.exe /s "#{node['timezone_iii']['timezone']}"
  EOH
  not_if { shell_out('tzutil.exe /g').stdout.include?(node['timezone_iii']['timezone']) }
end
