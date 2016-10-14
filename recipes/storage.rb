#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: cookbook-sentry
# Recipe:: storage
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

# Install storage-related dependent sofware, such as DB and cache

include_recipe 'redisio'
include_recipe 'redisio::enable'

include_recipe 'postgresql::server'
include_recipe 'postgresql::contrib'
include_recipe 'postgresql::config_pgtune'
include_recipe 'database::postgresql'

con = {
  :host     => '127.0.0.1',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}
node[cookbook_name]['postgresql']['db_map'].each do |dbx|

  if dbx.is_a?(Array)
    dbx_name = dbx[0]
    dbx = dbx[1]
  else
    dbx_name = dbx[:db_name]
  end

  postgresql_database_user dbx[:db_name] do
    connection con
    password   dbx[:db_pass]
    action     :create
  end

  postgresql_database dbx_name do
    connection con
    action     :create
    owner      dbx[:db_user]
  end

  postgresql_database_user dbx[:db_name] do
    connection    con
    database_name dbx_name
    privileges    [:all]
    action        :grant
  end
end
