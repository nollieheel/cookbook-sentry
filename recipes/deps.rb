#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: cookbook-sentry
# Recipe:: deps
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

# Install external dependencies of sentry

include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'cmake'

tarball = "#{Chef::Config[:file_cache_path]}"\
          "/cmake-#{node['cmake']['source']['version']}.tar.gz"
edit_resource!(:remote_file, tarball) do
  source   "http://www.cmake.org/files/"\
           "v#{node['cmake']['source']['version'][/^\d\.\d/, 0]}/"\
           "cmake-#{node['cmake']['source']['version']}.tar.gz"
  checksum node['cmake']['source']['checksum']
  notifies :run, 'execute[unpack cmake]', :immediately
end

edit_resource!(:execute, 'unpack cmake') do
  command  "tar xzf cmake-#{node['cmake']['source']['version']}.tar.gz"
  cwd      Chef::Config[:file_cache_path]
  notifies :run, 'execute[configure cmake]', :immediately
  notifies :run, 'execute[make cmake]', :immediately
  notifies :run, 'execute[make install cmake]', :immediately
  action   :nothing
end

python_runtime '2'

package node[cookbook_name]['deps']['packages']

node[cookbook_name]['deps']['symlinks'].each do |lname, target|
  link lname do
    to target
  end
end

apt_repository 'git' do
  uri 'ppa:git-core/ppa'
  distribution node['lsb']['codename']
end
include_recipe 'git'
include_recipe 'nodejs'
