#
# Cookbook Name:: gerrit
# Recipe:: peer_keys
#
# Copyright 2012, Steffen Gebert / TYPO3 Association
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

ssh_key_filename = "id_rsa-gerrit-code-review"
ssh_key = node['gerrit']['home'] + "/.ssh/" + ssh_key_filename

if node['gerrit']['peer_keys']['public'] == nil

  execute "generate private ssh key for 'Gerrit Code Review' user" do
    command "ssh-keygen -t rsa -q -f #{ssh_key} -P \"\""
    user node['gerrit']['user']
    group node['gerrit']['group']
    creates ssh_key
  end

  ruby_block "save keys to attributes" do
    block do
      private_key = File.open(ssh_key, "r").gets
      public_key = File.open(ssh_key + ".pub", "r").gets
      node.set['gerrit']['peer_keys']['private'] = private_key
      node.set['gerrit']['peer_keys']['public'] = public_key
    end
  end
end

file node['gerrit']['install_dir'] + "/etc/peer_keys" do
  contents = node['gerrit']['peer_keys']['public'].split(" ").slice(1)
  owner node['gerrit']['user']
  group node['gerrit']['user']
  notifies :restart, "service[gerrit]"
end

file ssh_key do
  content = node['gerrit']['peer_keys']['private']
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0600
end

file ssh_key + ".pub" do
  content = node['gerrit']['peer_keys']['public']
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0644
end