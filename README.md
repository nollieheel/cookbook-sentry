# cookbook-sentry-cookbook

Installs the [Sentry](https://docs.sentry.io/) error-logging software and all dependencies. Installation steps are taken from the official [instructions](https://docs.sentry.io/server/installation/python/).

## Supported Platforms

Only tested to work in Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['install']['user']</tt></td>
    <td>String</td>
    <td>User that runs Sentry</td>
    <td><tt>'sentry'</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['install']['conf_dir']</tt></td>
    <td>String</td>
    <td>Subdirectory where Sentry conf files are placed</td>
    <td><tt>'~/.sentry'</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['install']['log_dir']</tt></td>
    <td>String</td>
    <td>Subdirectory where log files are placed</td>
    <td><tt>'/var/log/sentry'</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['swap']['swapfile']</tt></td>
    <td>String, Boolean False</td>
    <td>Location of swapfile to enable. This is useful for machines with not enough RAM to fully install Sentry dependencies. A `false` value disables this feature.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['swap']['size']</tt></td>
    <td>String</td>
    <td>Size of swap file if used</td>
    <td><tt>'2G'</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['deps']['packages']</tt></td>
    <td>Array</td>
    <td>OS packages to install beforehand</td>
    <td><tt>['python-dev', 'libxml2-dev', 'libxslt1-dev', 'libffi-dev', 'libjpeg-dev', 'libyaml-dev', 'libpq-dev', 'clang-3.8']</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['deps']['symlinks']</tt></td>
    <td>Hash</td>
    <td>Some symbolic links might need creating in order to prep the machine, so this is a place to set that. Each hash key-pair is of the format: 'link_name' =&gt; 'target'.</td>
    <td><tt>{ '/usr/bin/clang' =&gt; '/usr/bin/clang-3.8', '/usr/bin/clang++' =&gt; '/usr/bin/clang++-3.8' }</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['python']['modules']</tt></td>
    <td>Array</td>
    <td>Array of dependent Python modules (and optional versions) to install. This is also where the main Sentry software is installed, along with its plugins.</td>
    <td><tt>[ ['requests[security]', '2.11.1'], ['amqp', '1.4.9'], ['anyjson', '0.3.3'], ['billiard', '3.3.0.23'], ['contextlib2', '0.5.4'], ['python-utils', '2.0.0'], ['pytz', '2016.7'], ['six', '1.10.0'], ['sqlparse', '0.2.1'], ['sentry', '8.9.0'], 'sentry-github', 'sentry-gitlab', 'sentry-zabbix', 'sentry-slack' ]</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['postgresql']['db_map']</tt></td>
    <td>Array</td>
    <td>Array of hashes that designate the databases and users/roles to be created in Postgresql</td>
    <td><tt>[ { :db_name =&gt; 'sentry', :db_user =&gt; 'sentry', :db_pass =&gt; 'secretpassword' } ]</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['config']['admin_email']</tt></td>
    <td>String</td>
    <td>Email address of the first user to be created</td>
    <td><tt>'admin@example.com'</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['config']['admin_pass']</tt></td>
    <td>String</td>
    <td>Password of the first user to be created</td>
    <td><tt>'secretpassword'</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['config']['cron']['cleanup_days']</tt></td>
    <td>Integer</td>
    <td>Number of days before records are considered stale whenever `sentry cleanup` is done</td>
    <td><tt>30</tt></td>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['config']['cron']['sched']</tt></td>
    <td>String</td>
    <td>When to actually do `sentry cleanup`. Must be in crontab format.</td>
    <td><tt>'0 0 * * *'</tt></td>
  </tr>
</table>

## Usage

### PostgreSQL and Redis

Configure PostgreSQL and Redis using their corresponding cookbooks, particulary passwords, software versions, and bind addresses. See default attribute file for default example values.

### Config files template

As of Sentry v8, there are two config files: `config.yml` and `sentry.conf.py`. You can provide your own template for both these files in your wrapper cookbook, then set the value of both these attributes to your cookbook's name:

```
node['cookbook-sentry']['config']['config.yml']['cookbook']
node['cookbook-sentry']['config']['sentry.conf.py']['cookbook']
```

You can also use the following attributes to pass variables into the corresponding templates:

```
node['cookbook-sentry']['config']['config.yml']['vars']
node['cookbook-sentry']['config']['sentry.conf.py']['vars']
```

`cookbook-sentry` already provides default templates for the above config files.

### cookbook-sentry::default

Include `cookbook-sentry` in your node's `run_list` to install Sentry:

```json
{
  "run_list": [
    "recipe[cookbook-sentry::default]"
  ]
}
```

## License and Authors

Author:: Earth U (<iskitingbords @ gmail.com>)
