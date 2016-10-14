#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: cookbook-sentry
# Recipe:: python
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

# Install Python packages, including Sentry itself

priv = "#{node[cookbook_name]['install']['home']}/priv"
reqs = "#{priv}/requirements.txt"

directory priv

template reqs do
  owner node[cookbook_name]['install']['user']
  group node[cookbook_name]['install']['group']
  variables(
    :modules => node[cookbook_name]['python']['modules']
  )
end

pip_requirements reqs
