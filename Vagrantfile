# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# TODO get user runnning vagrant up
# $host_home = File.expand_path "~"
$box = "debian/jessie64"
$vm_name = "jessie"
$vm_gui = false
$vm_memory = 1024*2 # TODO configurable memory
$vm_cpus = 1        # TODO configurable cpus

# shared folders follow a `host:guest` format with multiples being comma 
# separated
#
$shared_folders = {}
(ENV["VAGRANT_MOUNTS"] || ".:/vagrant").split(",").each do |mount|
  host, guest = mount.split(":")
  if guest.nil? || guest == ""
    guest = host
  end

  $shared_folders[host] = guest
end

Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 30

  # base configuration
  #
  config.vm.define $vm_name do |c|
    c.vm.box = $box

    c.vm.provider :virtualbox do |vb|
      vb.gui = $vm_gui
      vb.memory = $vm_memory
      vb.cpus = $vm_cpus
    end

    c.vm.hostname = $vm_name

    $shared_folders.each do |host, local|
      # TODO pass in owner
      c.vm.synced_folder host, local, owner: "nowk"
    end
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  [
    1337, 
    7331, 
    3000, 
    4000
  ].each do |port|
    config.vm.network "forwarded_port", guest: port, host: port
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
  # TODO pass in user to build.sh which should create the user
  config.vm.provision "shell", path: "build.sh"
end
