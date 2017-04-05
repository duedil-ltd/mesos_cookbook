
# Grab the cluster name we want to use
zk_cluster_name = node[:mesos][:duedil_dns_discovery][:zk][:cluster_name]
raise "A zk:cluster_name is required for auto discovery" if zk_cluster_name.nil?

# Figure out which domain to look for zookeeper in
zk_domain = node[:mesos][:duedil_dns_discovery][:zk][:domain] || node[:domain]

# Discover the zookeeper nodes
zk_instances = DNSDiscovery::Helper.discover_instances("zookeeper-client", zk_domain, :subtype => zk_cluster_name)
raise "No zookeeper instances could be discovered" if zk_instances.nil? || zk_instances.size == 0

# Build the list
hostnames = []
zk_instances.each do |instance|
    hostnames << "#{instance.target}:#{instance.port}"
end

# Create the ZK string attribute
zk_string = "zk://"
zk_string << hostnames.sort.join(",")
zk_string << "/" + node['mesos']['zookeeper_path']

# Set the relevant attributes
node.override['mesos']['master']['flags']['zk'] = zk_string
node.override['mesos']['slave']['flags']['master'] = zk_string

