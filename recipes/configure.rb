#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: cookbook-sentry
# Recipe:: configure
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

# Install Sentry and initiate

require 'shellwords'

installvars  = node[cookbook_name]['install']
configvars   = node[cookbook_name]['config']
configyml    = "#{installvars['conf_dir']}/config.yml"
sentryconfpy = "#{installvars['conf_dir']}/sentry.conf.py"

directory installvars['conf_dir'] do
  owner     installvars['user']
  group     installvars['group']
  recursive true
end

template configyml do
  owner     installvars['user']
  group     installvars['group']
  cookbook  configvars['config.yml']['cookbook']
  notifies  :run, 'ruby_block[populate_secret_key]', :immediately
  variables(
    :vars => configvars['config.yml']['vars']
  )
end

template sentryconfpy do
  owner     installvars['user']
  group     installvars['group']
  cookbook  configvars['sentry.conf.py']['cookbook']
  variables(
    :vars => configvars['sentry.conf.py']['vars']
  )
end

suuser    = "su #{installvars['user']} -l -c"
sentrycom = "#{configvars['sentry_bin']} --config #{installvars['conf_dir']}"
gensecret = "#{suuser} '#{sentrycom} config generate-secret-key'"

ruby_block 'populate_secret_key' do
  block do
    text  = ::File.read(configyml)
    text2 = text.gsub(/SECRET_KEY/, %x( #{gensecret} ).strip)

    ::File.open(configyml, 'w') { |file| file.puts text2 }
  end
  action :nothing
end

envvars = {
  'PATH' =>      configvars['sentry_env']['path'],
  'NODE_PATH' => configvars['sentry_env']['node_path'],
  'HOME' =>      installvars['home'],
  'USER' =>      installvars['user'],
  'LOGNAME' =>   installvars['user'],
  'LANG' =>      'en_US.UTF-8'
}

bash 'sentry_upgrade' do
  user  installvars['user']
  group installvars['group']
  code  "#{sentrycom} upgrade --noinput | tee -a /tmp/sentry_upgrade.output"
  environment envvars
end

adminuserflag = "#{installvars['conf_dir']}/.admin_user"
supertext = configvars['admin_superuser'] ? "--superuser " : "--no-superuser"

bash 'sentry_createuser' do
  user  installvars['user']
  group installvars['group']
  code  "#{sentrycom} createuser --no-input #{supertext} "\
        "--email #{configvars['admin_email'].shellescape} "\
        "--password #{configvars['admin_pass'].shellescape} "\
        "| tee -a /tmp/sentry_createuser.output"

  not_if      { ::File.exist?(adminuserflag) }
  notifies    :create, "file[#{adminuserflag}]"
  environment envvars
end

file adminuserflag do
  content configvars['admin_email']
  action  :nothing
end
