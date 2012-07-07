maintainer        "Mike Fiedler"
maintainer_email  "miketheman@gmail.com"
license           "Apache 2.0"
description       "Installs and configures the Scout Agent"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.4.0"

%w{centos redhat debian ubuntu amazon}.each do |os|
  supports os
end
