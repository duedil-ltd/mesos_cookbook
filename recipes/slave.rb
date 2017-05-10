#
# Cookbook Name:: mesos
# Recipe:: slave
#
# Copyright (C) 2015 Medidata Solutions, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef::Recipe
  include MesosHelper
end

directory node['mesos']['slave']['flags']['work_dir']

include_recipe 'mesos_pkg::install'

# Mesos configuration validation
ruby_block 'mesos-slave-configuration-validation' do
  block do
    # Get Mesos --help
    help = Mixlib::ShellOut.new("#{node['mesos']['slave']['bin']} --help --work_dir=#{node['mesos']['slave']['flags']['work_dir']}")
    help.run_command
    help.error!
    # Extract options
    options = help.stdout.strip.scan(/^  --(?:\[no-\])?(\w+)/).flatten - ['help']
    # Check flags are in the list
    node['mesos']['slave']['flags'].keys.each do |flag|
      unless options.include?(flag)
        Chef::Application.fatal!("Invalid Mesos configuration option: #{flag}. Aborting!", 1000)
      end
    end
  end
end

# ZooKeeper discovery
if node['mesos']['zookeeper_exhibitor_discovery'] && node['mesos']['zookeeper_exhibitor_url']
  # Exhibitor
  zk_nodes = MesosHelper.discover_zookeepers_with_retry(node['mesos']['zookeeper_exhibitor_url'])
  node.override['mesos']['slave']['flags']['master'] = 'zk://' + zk_nodes['servers'].map { |s| "#{s}:#{zk_nodes['port']}" }.join(',') + '/' + node['mesos']['zookeeper_path']
elsif node['mesos']['zookeeper_duedil_dns_discovery'] && node['mesos']['duedil_dns_discovery']
  # Duedil DNSDiscovery
  include_recipe "mesos_pkg::discovery_zk"
end

# this directory doesn't exist on newer versions of Mesos, i.e. 0.21.0+
directory '/usr/local/var/mesos/deploy/' do
  recursive true
end

# Mesos slave configuration wrapper
template 'mesos-slave-wrapper' do
  path '/etc/mesos-chef/mesos-slave'
  owner 'root'
  group 'root'
  mode '0750'
  source 'wrapper.erb'
  variables(env:    node['mesos']['slave']['env'],
            bin:    node['mesos']['slave']['bin'],
            flags:  node['mesos']['slave']['flags'],
            syslog: node['mesos']['slave']['syslog'])
end

# Set-up a cron job to clean out old slave directories
# When the mesos slave starts up, it will discover previous slave working dirs
# and schedule them for cleanup. Due to an intermittent bug (likely due to mounted
# directories inside the work dir) sometimes the rmr fails, and isn't re-scheduled
# causing a build up of old directories over time. To combat this in the short term
# until a better solution is found, we can just remove the old directories on a cron.
# See this thread: https://mail-archives.apache.org/mod_mbox/mesos-user/201507.mbox/browser
template "#{node['mesos']['slave']['flags']['work_dir']}/cleanup.sh" do
    source "slave_cleanup.sh.erb"
    mode 0755

    variables(
        :work_dir => node['mesos']['slave']['flags']['work_dir']
    )
end

cron "mesos_slave_cleanup" do
    command "#{node['mesos']['slave']['flags']['work_dir']}/cleanup.sh"
    minute "0,30"
    hour "*"
    day "*"
    weekday "*"
    month "*"

    action :create
end

# Mesos master service definition
service 'mesos-slave' do
  case node['mesos']['init']
  when 'systemd'
    provider Chef::Provider::Service::Systemd
  when 'sysvinit_debian'
    provider Chef::Provider::Service::Init::Debian
  when 'upstart'
    provider Chef::Provider::Service::Upstart
  end
  supports status: true, restart: true
  subscribes :restart, 'template[mesos-slave-init]'
  subscribes :restart, 'template[mesos-slave-wrapper]'
  action [:enable, :start]
end
