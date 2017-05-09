# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version '>= 1.5.0'

$script = <<SCRIPT
# Install docker
sudo apt-get install -y\
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sed -i 's_fd://_fd:// --insecure-registry registry.docker.duedil.net_' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker.service
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.chef_version = 'latest'
  end

  config.vm.box = 'debian/contrib-jessie64'
  config.vm.synced_folder "/Users/dmilanp/DueDil/Repos", "/duedil"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 443, host: 4443

  # First machine
  config.vm.define "first", primary: true do |first|
    first.vm.network "private_network", ip: "192.168.33.33"
    first.vm.hostname = "mesos"
  end

  # Second machine
  # config.vm.define "second" do |second|
  #   second.network "private_network", ip: "192.168.33.34"
  # end

  # Berkshelf
  config.berkshelf.enabled = true

  # Configure memory and cpus
  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision :chef_solo do |chef|

    # Provide json
    chef.json = {
      'java' => {'jdk_version' => '7'},
      'mesos' =>{
        'version' => '1.1.0',
        'master' => {
          'flags' => {
            'ip' => '192.168.33.33'
          }
        },
        'slave' => {
          'flags' => {
            'ip' => '192.168.33.33',
            'master' => 'zk://192.168.33.33:2181/mesos'
          }
        }
      }

    }

    # Provide run list
    chef.run_list = [
        'recipe[zookeeper::default]',
        'recipe[mesos_v2::master]',
        'recipe[mesos_v2::slave]',
    ]

  end

  config.vm.provision "shell", inline: $script

end
