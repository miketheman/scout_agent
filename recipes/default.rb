#
# Cookbook Name:: scout_agent
# Recipe:: default

# create user and group
group node[:scout_agent][:group] do
  action [ :create, :manage ]
end
user node[:scout_agent][:user] do
  comment "Scout Agent"
  gid node[:scout_agent][:group]
  home "/home/#{node[:scout_agent][:user]}"
  supports :manage_home => true
  action [ :create, :manage ]
end

# install scout agent gem
# Method used is referenced here: http://www.opscode.com/blog/2009/06/01/cool-chef-tricks-install-and-use-rubygems-in-a-chef-run/
r = gem_package "scout" do
  version node[:scout_agent][:version]
  action :nothing
end
r.run_action(:install)

if node[:scout_agent][:key]
  Gem.clear_paths
  require 'scout'
  # we need to find where scout is installed
  scout_bin = `which scout`.strip()
  # initialize scout gem
  bash "initialize scout" do
    code <<-EOH
    #{scout_bin} #{node[:scout_agent][:key]}
    EOH
    cron_dir = value_for_platform(
      ["ubuntu", "debian"] => { "default" => "/var/spool/cron/crontabs/"},
      ["redhat", "centos", "fedora", "scientific", "amazon"] => { "default" => "/var/spool/cron/"},
      "default" => "/var/spool/cron/crontabs/"
    )
    not_if do File.exist?("#{cron_dir}/#{node[:scout_agent][:user]}") end
  end
  
  # schedule scout agent to run via cron
  cron "scout_run" do
    user node[:scout_agent][:user]
    command "#{scout_bin} #{node[:scout_agent][:key]} # Managed by chef"
    only_if do File.exist?("#{scout_bin}") end
  end
else
  Chef::Log.info "Add a [:scout_agent][:key] attribute to configure this node's Scout Agent"
end