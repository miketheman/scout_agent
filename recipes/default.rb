#
# Cookbook Name:: scout_agent
# Recipe:: default
#
# Copyright 2011-2012, Michael A. Fiedler
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

# create user and group
group node['scout_agent']['group'] do
  gid node['scout_agent']['gid']
  action [:create, :manage]
end
user node['scout_agent']['user'] do
  comment "Scout Agent"
  uid node['scout_agent']['uid']
  gid node['scout_agent']['group']
  home "/home/#{node['scout_agent']['user']}"
  supports :manage_home => true
  action [:create, :manage]
end

# install scout agent gem
if(Gem::Version.new(Chef::VERSION) < Gem::Version.new('0.10.9'))
  Chef::Log.debug 'Installing scout gem with trick method'
  # Method used is referenced here:
  # http://www.opscode.com/blog/2009/06/01/cool-chef-tricks-install-and-use-rubygems-in-a-chef-run/
  # TODO: Remove once 0.10.8 is fully end-of-life
  r = gem_package "scout" do
    version node['scout_agent']['version']
    action :nothing
  end
  r.run_action(:install)
  Gem.clear_paths
  require 'scout'
else
  # The chef_gem provider was introduced in Chef 0.10.10
  chef_gem "scout"
end

if node['scout_agent']['key']
  # we need to find where scout is installed
  # this may differ, depending on where chef is installed
  scout_bin = "#{Gem.bindir}/scout"

  # Run scout with --name set to node name.
  # See: https://scoutapp.com/info/support#cloud_naming
  name_part = node['scout_agent']['rename'] ? "--name=\"#{node.name}\"" : ""
  scout_cmd = "#{scout_bin} #{name_part} #{node['scout_agent']['key']}"

  # initialize scout gem
  bash "initialize scout" do
    code <<-EOH
    #{scout_cmd}
    EOH
    cron_dir = value_for_platform(
      ["ubuntu", "debian"] => { "default" => "/var/spool/cron/crontabs/" },
      ["redhat", "centos", "fedora", "scientific", "amazon"] => {
        "default" => "/var/spool/cron/"
      },
      "default" => "/var/spool/cron/crontabs/"
    )
    not_if do File.exist?("#{cron_dir}/#{node['scout_agent']['user']}") end
  end

  # schedule scout agent to run via cron
  cron "scout_run" do
    user node['scout_agent']['user']
    command "#{scout_cmd} # Managed by chef"
    only_if do File.exist?(scout_bin) end
  end
else
  Chef::Log.info "Add a `node['scout_agent']['key']` attribute for Scout Agent."
end
