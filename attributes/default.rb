# Default Java version
default['java']['jdk_version'] = '8'

# Use Mesosphere repo
default['mesos']['repo']       = true

# Mesosphere Mesos version.
default['mesos']['version']    = '1.1.0'

# Init system to use
default['mesos']['init']       = case node['platform']
                                 when 'debian'
                                   node['platform_version'].to_i >= 8 ? 'systemd' : 'sysvinit_debian'
                                 when 'ubuntu'
                                   node['platform_version'].to_f >= 15.04 ? 'systemd' : 'upstart'
                                 when 'redhat', 'centos', 'scientific', 'oracle' # ~FC024
                                   node['platform_version'].to_i >= 7 ? 'systemd' : 'upstart'
                                 else 'upstart'
                                 end

#
# Mesos MASTER configuration
#

# Mesos master binary location.
default['mesos']['master']['bin']                   = '/usr/sbin/mesos-master'

# Environmental variables set before calling the mesos master process.
default['mesos']['master']['env']['ULIMIT']         = '-n 16384'

# Send stdout and stderr to syslog.
default['mesos']['master']['syslog']                = true

# Mesos master command line flags.
# http://mesos.apache.org/documentation/latest/configuration/
default['mesos']['master']['flags']['port']          = 5050
default['mesos']['master']['flags']['log_dir']       = '/var/log/mesos-' + node['mesos']['version'].gsub(/\./, '-')
default['mesos']['master']['flags']['logging_level'] = 'INFO'
default['mesos']['master']['flags']['cluster']       = 'MyMesosCluster'
default['mesos']['master']['flags']['work_dir']      = '/var/lib/mesos-master-' + node['mesos']['version'].gsub(/\./, '-')
default['mesos']['master']['flags']['zk']            = 'zk://127.0.0.1:2181/mesos'
default['mesos']['master']['flags']['quorum']        = 1
default['mesos']['master']['flags']['ip']            = node[:ip]

#
# Mesos SLAVE configuration
#

# Mesos slave binary location.
default['mesos']['slave']['bin']                    = '/usr/sbin/mesos-slave'

# Environmental variables set before calling the mesos-slave process.
default['mesos']['slave']['env']['ULIMIT']          = '-n 16384'

# Send stdout and stderr to syslog.
default['mesos']['slave']['syslog']                 = true

# Mesos slave command line flags
# http://mesos.apache.org/documentation/latest/configuration/
default['mesos']['slave']['flags']['port']          = 5051
default['mesos']['slave']['flags']['log_dir']       = '/var/log/mesos-' + node['mesos']['version'].gsub(/\./, '-')
default['mesos']['slave']['flags']['logging_level'] = 'INFO'
default['mesos']['slave']['flags']['work_dir']      = '/var/lib/mesos-slave-' + node['mesos']['version'].gsub(/\./, '-')
default['mesos']['slave']['flags']['isolation']     = 'posix/cpu,posix/mem'
default['mesos']['slave']['flags']['master']        = 'zk://127.0.0.1:2181/mesos'
default['mesos']['slave']['flags']['strict']        = true
default['mesos']['slave']['flags']['recover']       = 'reconnect'
default['mesos']['slave']['flags']['ip']            = node[:ip]

# Workaround for setting default cgroups hierarchy root
default['mesos']['slave']['flags']['cgroups_hierarchy'] = if node['mesos']['init'] == 'systemd'
                                                            '/sys/fs/cgroup'
                                                          else
                                                            '/cgroup'
                                                          end

# Use the following options if you are using Exhibitor to manage Zookeeper
# in your environment.

# Zookeeper path that Mesos will use to write to.
default['mesos']['zookeeper_path']                      = 'mesos'

# Flag to enable Zookeeper ensemble discovery via Netflix Exhibitor.
default['mesos']['zookeeper_exhibitor_discovery']       = false

# Flag to enable Zookeeper ensemble discovery via Duedil DNSDiscovery.
default['mesos']['zookeeper_duedil_dns_discovery']         = false

default['mesos']['duedil_dns_discovery']['cluster_name'] = nil, # Required for discovery to work
default['mesos']['duedil_dns_discovery']['web_ui_service_name'] = "http",
default['mesos']['duedil_dns_discovery']['master_service_name'] = "mesos-master",
default['mesos']['duedil_dns_discovery']['slave_service_name'] = "mesos-slave",
default['mesos']['duedil_dns_discovery']['zk']['domain'] = node[:domain],
default['mesos']['duedil_dns_discovery']['zk']['cluster_name'] = nil, # Required for ZK discovery to work
default['mesos']['duedil_dns_discovery']['zk']['service_name'] = "zookeeper-client",


# Netflix Exhibitor ZooKeeper ensemble url.
default['mesos']['zookeeper_exhibitor_url']             = nil
