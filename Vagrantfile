# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
configs        = YAML.load_file("#{current_dir}/config.yaml")
vm_disks    = configs['disks']
vm_disk_path = "D:/VirtualBoxVM/oel67bare/"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  config.vm.define "oel67bare", primary: true do |oel67bare|
    oel67bare.vm.box = "OEL6_7-x86_64"
    oel67bare.vm.box_url = "file:///D:/Packer_VM/VirtualBox/OEL6_7_Docker-x86_64.box"

    oel67bare.vm.provider :vmware_fusion do |v, override|
      override.vm.box = "OEL6_7-x86_64-vmware"
      override.vm.box_url = "file:///D:/Packer_VM/VirtualBox/OEL6_7_Docker-x86_64.box"
    end

    oel67bare.vm.hostname = "oel67bare.example.com"
    oel67bare.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
    oel67bare.vm.synced_folder "D:/Oracle 12c", "/software"
    
#    oel67bare.vm.network :private_network, ip: "10.10.10.7", name: "VirtualBox Host-Only Ethernet Adapter"
     oel67bare.vm.network "forwarded_port", guest: 1521, host: 1521

    oel67bare.vm.provider :vmware_fusion do |vb|
      vb.vmx["numvcpus"] = "2"
      vb.vmx["memsize"] = "4096"
    end

    oel67bare.vm.provider :virtualbox do |vb|
      vb.gui=true
      vb.customize ["modifyvm"     , :id, "--memory", "4096"]
      vb.customize ["modifyvm"     , :id, "--name"  , "oel67bare"]
      vb.customize ["modifyvm"     , :id, "--cpus"  , 2]
      vb.customize ["modifyvm"     , :id, "--vram"  , "64"]

      vm_disks.each do |disks|
        unless File.exist?(vm_disk_path+disks["file_name"])
          vb.customize ["createhd", "--filename", vm_disk_path+disks["file_name"], "--size", disks["size_gb"] * 1024]
        end        
        vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", disks["id"], "--device", 0, "--type", "hdd", "--medium", vm_disk_path+disks["file_name"]]
      end
    end

    oel67bare.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppet/hiera.yaml;rm -rf /etc/puppet/modules;ln -sf /vagrant/puppet/modules /etc/puppet/modules"

    oel67bare.vm.provision :puppet do |puppet|
      puppet.manifests_path    = "puppet/manifests"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "site.pp"
      puppet.options           = "--verbose --hiera_config /vagrant/puppet/hiera.yaml  --parser future"

      puppet.facter = {
        "environment" => "development",
        "vm_type"     => "vagrant",
      }
    end

  end

end

