#
# Cookbook Name:: ejabberd
# Recipe:: default
#
# Copyright (C) 2013 Mojo Lingo
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

case node['platform']
when 'debian'
  include_recipe 'apt'
when 'ubuntu'
  include_recipe 'apt'
  if node['platform_version'].to_f == 14.04
    apt_repository "ejabberd-rx22" do
      uri "http://ppa.launchpad.net/rx22/ejabberd1407/ubuntu"
      distribution node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "3E5EA079"
    end
  end
when 'centos', 'redhat', 'amazon', 'scientific'
  include_recipe 'yum-epel::default'
end

package "ejabberd"

service "ejabberd" do
  action :enable
end

case node['platform']
when 'ubuntu'
  if node['platform_version'].to_f >= 14.04
    template "/etc/ejabberd/ejabberd.yml" do
      source "ejabberd.yml.erb"
      owner 'ejabberd'
      group 'ejabberd'
      mode '640'
      variables :jabber_domain => node['ejabberd']['jabber_domain']
      notifies :restart, resources('service[ejabberd]')
    end
  else
    template "/etc/ejabberd/ejabberd.cfg" do
      source "ejabberd.cfg.erb"
      owner 'ejabberd'
      group 'ejabberd'
      mode '640'
      variables :jabber_domain => node['ejabberd']['jabber_domain']
      notifies :restart, resources('service[ejabberd]')
    end
  end
end
