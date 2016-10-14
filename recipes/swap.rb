#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: cookbook-sentry
# Recipe:: swap
#
# Copyright 2016, Earth U
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
#

# Low RAM (=< 1G) can cause 'sentry upgrade' to lock up, so enable some swap.

swapfile = node[cookbook_name]['swap']['swapfile']

bash 'enable_swap' do
  code <<-EOF.gsub(/^\s+/, '')
    set -e

    if [[ ! -f #{swapfile} ]] ; then
      fallocate -l #{node[cookbook_name]['swap']['size']} #{swapfile}
      chmod 600 #{swapfile}
      mkswap #{swapfile}
      swapon #{swapfile}
      echo "#{swapfile} none swap sw 0 0" >> /etc/fstab
    fi
  EOF
  only_if { swapfile }
end
