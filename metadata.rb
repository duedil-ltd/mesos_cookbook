name             'mesos_pkg'
maintainer       'DueDil Infrastructure team'
maintainer_email 'infra@duedil.com'
license          'Apache 2.0'
description      'Installs/Configures Apache Mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.6.1'
source_url       'https://github.com/duedil-ltd/mesos_cookbook'
issues_url       'https://github.com/duedil-ltd/mesos_cookbook/issues'

%w(ubuntu debian centos amazon scientific oracle).each do |os|
  supports os
end

%w(java apt yum dnsdiscovery).each do |cookbook|
  depends cookbook
end
