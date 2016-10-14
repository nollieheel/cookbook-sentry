#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: cookbook-sentry
# Attribute:: default
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

cb = 'cookbook-sentry'

default[cb]['install']['user']     = 'sentry'
default[cb]['install']['group']    = node[cb]['install']['user']
default[cb]['install']['home']     = "/home/#{node[cb]['install']['user']}"
default[cb]['install']['conf_dir'] = "#{node[cb]['install']['home']}/.sentry"
default[cb]['install']['log_dir']  = '/var/log/sentry'

# Location of swap file (e.g. '/swapfile')
default[cb]['swap']['swapfile'] = false
default[cb]['swap']['size']     = '2G'

default[cb]['deps']['packages'] = %w{
  python-dev libxml2-dev libxslt1-dev libffi-dev libjpeg-dev
  libyaml-dev libpq-dev clang-3.8
}
default[cb]['deps']['symlinks'] = {
  '/usr/bin/clang'   => '/usr/bin/clang-3.8',
  '/usr/bin/clang++' => '/usr/bin/clang++-3.8'
}

default[cb]['python']['modules'] = [
  ['requests[security]', '2.11.1'],
  ['amqp', '1.4.9'],
  ['anyjson', '0.3.3'],
  ['billiard', '3.3.0.23'],
  ['contextlib2', '0.5.4'],
  ['python-utils', '2.0.0'],
  ['pytz', '2016.7'],
  ['six', '1.10.0'],
  ['sqlparse', '0.2.1'],

  # Sentry will be installed as a pip package here:
  ['sentry', '8.9.0'],

  # Sentry plugins can be installed together as pip packages:
  'sentry-github',
  'sentry-gitlab',
  'sentry-zabbix',
  'sentry-slack'
]

default[cb]['postgresql']['db_map'] = [
  {
    :db_name => 'sentry',
    :db_user => 'sentry',
    :db_pass => 'secretpassword'
  }
]

default['apt']['compile_time_update']      = true
default['build-essential']['compile_time'] = true

default['cmake']['install_method']     = 'source'
default['cmake']['source']['version']  = '3.6.2'
default['cmake']['source']['checksum'] =
  '189ae32a6ac398bb2f523ae77f70d463a6549926cde1544cd9cc7c6609f8b346'

default['nodejs']['engine'] = 'node'
default['nodejs']['repo']   = 'https://deb.nodesource.com/node_6.x'
# The latest NPM will already come with Node v6.x
#default['nodejs']['npm_packages'] = [ { 'name' => 'npm' } ]

default['redisio']['version']  = '3.2.4'
override['redisio']['servers'] = [ {
  'name'    => '_sentry',
  'address' => '127.0.0.1',
  'port'    => '6379'
} ]

default['postgresql']['password']['postgres']     = 'secretpassword'
default['postgresql']['config_pgtune']['db_type'] = 'web'

# The first user to be created. Usually should be a superuser.
default[cb]['config']['admin_email']     = 'admin@example.com'
default[cb]['config']['admin_pass']      = 'secretpassword'
default[cb]['config']['admin_superuser'] = true

default[cb]['config']['cron']['cleanup_days']   = 30
default[cb]['config']['cron']['sched']          = '0 0 * * *'
default[cb]['config']['cron']['mailto']         = "''"
default[cb]['config']['cron']['logrotate_opts'] = %w{
  weekly
  rotate\ 10
  missingok
  compress
  notifempty
}

# Some constants.

default[cb]['config']['sentry_bin'] = '/usr/local/bin/sentry'
default[cb]['config']['sentry_env']['path'] =
  '/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games'
default[cb]['config']['sentry_env']['node_path'] =
  '/usr/lib/nodejs:/usr/lib/node_modules:/usr/share/javascript'
default[cb]['config']['cron']['logrotate_dir'] = '/etc/logrotate.d'

# Default config file templates

default[cb]['config']['config.yml']['cookbook'] = cb
default[cb]['config']['config.yml']['vars'] = {
  :mail_backend => 'smtp',
  :mail_host    => 'localhost',
  :mail_port    => 25,
  :mail_from    => 'info@example.com',
  :redis_host   => node['redisio']['servers'][0]['address'],
  :redis_port   => node['redisio']['servers'][0]['port'],
  :more_opts    => []
}

default[cb]['config']['sentry.conf.py']['cookbook'] = cb
default[cb]['config']['sentry.conf.py']['vars'] = {
  :db_name     => node[cb]['postgresql']['db_map'][0][:db_name],
  :db_user     => node[cb]['postgresql']['db_map'][0][:db_user],
  :db_pass     => node[cb]['postgresql']['db_map'][0][:db_pass],
  :db_host     => node['postgresql']['config']['listen_addresses'],
  :db_port     => node['postgresql']['config']['port'],
  :redis_host  => node['redisio']['servers'][0]['address'],
  :redis_port  => node['redisio']['servers'][0]['port'],
  :web_host    => '0.0.0.0',
  :web_port    => 9000,
  :web_ssl     => false,
  :web_workers => 3,
  :more_opts   => []
}
