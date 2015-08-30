# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"

# TODO get user runnning vagrant up
$box = "debian/jessie64"
$vm_name = "jessie"
$vm_gui = false
$vm_memory = 1024*4 # TODO configurable memory
$vm_cpus = 1        # TODO configurable cpus

# to_mount takes a string and returns an object describing each shared mount
# the string takes the standard format of host:guest,...
def to_mount(str)
  str ||= ""

  str.split(",").inject({}) do |memo, obj|
    host, guest = obj.split(":")

    if guest.nil? || guest == ""
      guest = host
    end

    memo[host] = guest
    memo
  end
end

# secondary drive
# secondary_drive =  'drive-01.vdi'

Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 60

  # base configuration
  #
  config.vm.define $vm_name do |c|
    c.vm.box = $box

    c.vm.provider :virtualbox do |vb|
      vb.gui = $vm_gui
      vb.memory = $vm_memory
      vb.cpus = $vm_cpus

      # disable nested paging, causing 100% cpu
      # http://www.dotnetmafia.com/blogs/dotnettipoftheday/archive/2010/09/22/fix-high-guest-cpu-utilization-in-virtualbox-by-disabling-nested-paging.aspx
      vb.customize "pre-boot", ['modifyvm', :id, '--nestedpaging', 'off']

      # Attaching additional storage
      # NOTE these are better off handled via VBoxManage commands
      #
      # Create drive:
      #
      #   $ VBoxManage createhd --filename <drive-name>.vdi --size 16384
      #
      # Attach drive:
      #
      #   $ VBoxManage storageattach <vi id> \
      #     --storagectl "SATA Controller" --port 1 --device 0 --type hdd
      #     --medium <drive-name>.vdi
      #
      # If you don't have controller setup:
      #
      #   $ VBoxManage storagectl <vm id> \
      #     --name "SATA Controller" --add sata --controller IntelAHCI
      #
      # If you need to change the UUID due to a detachment or other
      #
      #   $ VBoxManage internalcommands sethduuid <drive name>.vdi
      #
      # Handly commands when dealing with storage
      #
      #   $ VBoxManage list vms
      #   $ VBoxManage list hdds
      #   $ VBoxManage closemedium disk <uuid> --delete
      #
      # Within vagrant
      #
      #   unless File.exist?(secondary_drive)
      #     vb.customize ['createhd', '--filename', secondary_drive, '--size', 16 * 1024]
      #     vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', secondary_drive]
      #   end
    end

    c.vm.hostname = $vm_name

    # shared folders
    #
    # sshfs
    # TODO current vagrant-sshfs plugin does not seem to work
    # c.sshfs.mount_on_guest = true
    # c.sshfs.sudo = true
    # c.sshfs.options = "-o cache=yes -o Ciphers=arcfour -o reconnect,kernel_cache,large_read -o compression=no"
    # c.sshfs.username = 'nowk'
    # c.sshfs.host_addr = '10.0.2.2'
    # c.sshfs.paths = {
    #   "/home/nowk/devs" => "/home/nowk/devs"
    # }

    # standard guest access
    to_mount(ENV["VAGRANT_MOUNTS"]).each do |host, local|
      c.vm.synced_folder host, local, owner: "nowk" # TODO pass in owner
    end

    # remove default shared folder
    c.vm.synced_folder '.', '/vagrant', disabled: true
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  [
    1337,
    7331,
    3000, 3001, 3002, 3003, 3004, 3005,
    4000, 4001, 4002, 4003, 4004, 4005,
    5000, 5001, 5002, 5003, 5004, 5005,
    6000, 6001, 6002, 6003, 6004, 6005,
    8888 # btsync
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
