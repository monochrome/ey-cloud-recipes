#
# Cookbook Name:: redis_nutmeg
# Recipe:: default
#

if ['util'].include?(node[:instance_role])

execute "set_overcommit_memory" do
  command "echo 1 > /proc/sys/vm/overcommit_memory"
  action :run
end

enable_package "dev-db/redis" do
  version "2.2.11"
end

package "dev-db/redis" do
  version "2.2.11"
  action :upgrade
end

directory "/data/redis_nutmeg" do
  owner 'redis'
  group 'redis'
  mode 0755
  recursive true
  action :create
end

template "/etc/redis_nutmeg_util.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis_nutmeg.conf.erb"
  variables({
    :pidfile => '/var/run/redis_nutmeg_util.pid',
    :basedir => '/data/redis_nutmeg',
    :logfile => '/data/redis_nutmeg/redis_nutmeg.log',
    :port  => '6389',
    :loglevel => 'notice',
    :timeout => 300000,
  })
end

template "/data/monit.d/redis_nutmeg_util.monitrc" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis_nutmeg.monitrc.erb"
  variables({
    :profile => '1',
    :configfile => '/etc/redis_nutmeg_util.conf',
    :pidfile => '/var/run/redis_nutmeg_util.pid',
    :logfile => '/data/redis_nutmeg',
    :port => '6389',
  })
end

execute "monit reload" do
  action :run
end
end
