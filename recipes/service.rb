#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: cookbook-sentry
# Recipe:: service
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

# Install Supervisor and configure Sentry as a service

installvars = node[cookbook_name]['install']
configvars  = node[cookbook_name]['config']

include_recipe 'supervisor'

directory installvars['log_dir'] do
  recursive true
end

sentrycom = "#{configvars['sentry_bin']} --config #{installvars['conf_dir']}"

workcon = ""
unless configvars['worker']['concurrency'].nil?
  workcon = " -c #{configvars['worker']['concurrency']}"
end

[
  {
    :name => 'worker',
    :comm => "#{sentrycom} run worker#{workcon}"
  },
  {
    :name => 'cron',
    :comm => "#{sentrycom} run cron"
  },
  {
    :name => 'web',
    :comm => "#{sentrycom} run web"
  }
].each do |x|
  supervisor_service "sentry_#{x[:name]}" do
    command      x[:comm]
    directory    installvars['home']
    user         installvars['user']
    autostart    true
    autorestart  true
    startretries 5
    stopsignal   'TERM'

    if x[:name] == 'worker' && !configvars['worker']['sup_numprocs'].nil? 
      numprocs_start 0
      numprocs       configvars['worker']['sup_numprocs']
    end

    environment(
      'PATH' =>      configvars['sentry_env']['path'],
      'NODE_PATH' => configvars['sentry_env']['node_path'],
      'HOME' =>      installvars['home'],
      'USER' =>      installvars['user'],
      'LOGNAME' =>   installvars['user'],
      'LANG' =>      'en_US.UTF-8'
    )

    stdout_logfile "#{installvars['log_dir']}/#{x[:name]}.log"
    stderr_logfile "#{installvars['log_dir']}/#{x[:name]}.err"

    stdout_logfile_maxbytes '1MB'
    stdout_logfile_backups  10
    stderr_logfile_maxbytes '1MB'
    stderr_logfile_backups  10
  end
end

sched = configvars['cron']['sched'].split(' ')
cron_d 'sentry_cleanup' do
  command "#{sentrycom} cleanup --days #{configvars['cron']['cleanup_days']} "\
          ">> #{installvars['log_dir']}/cleanup.log 2>&1"
  user    installvars['user']
  minute  sched[0]
  hour    sched[1]
  day     sched[2]
  month   sched[3]
  weekday sched[4]
  mailto  configvars['cron']['mailto']
  path    configvars['sentry_env']['path']
end

case node['platform']
when 'ubuntu'
  package 'logrotate'

  template "#{configvars['cron']['logrotate_dir']}/sentry_cleanup" do
    source 'logrotate.erb'
    only_if "test -d #{configvars['cron']['logrotate_dir']} "\
            "|| mkdir -p #{configvars['cron']['logrotate_dir']}"
    variables(
      :log_file => "#{installvars['log_dir']}/cleanup.log",
      :opts     => configvars['cron']['logrotate_opts']
    )
  end
end
