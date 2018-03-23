# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = 3

Vagrant.configure("2") do |config|


  config.vm.box = "centos/7"

  #Define Spark Nodes
  (0..nodes-1).each do |i|

        port_number = i + 4
        ip_address = "192.168.50.#{port_number}"
        #seed_addresses = "192.168.50.4,192.168.50.5,192.168.50.6"
        config.vm.define "node#{i}" do |node|
            node.vm.network "private_network", ip: ip_address
            node.vm.provider "virtualbox" do |vb|
                   vb.memory = "3096"
                   vb.cpus = 4
            end

            node.vm.provision "shell" do |s|
               s.inline = <<-SHELL
                sudo /vagrant/resources/bin/setup-host.sh $1
               SHELL
               s.args   = ["node#{i}"]
            end

            node.vm.provision "shell", inline: <<-SHELL
                sudo /vagrant/scripts/000-vagrant-provision.sh
            SHELL

        end
  end

  # # Define Bastion Node
  # config.vm.define "bastion" do |node|
  #           node.vm.network "private_network", ip: "192.168.50.20"
  #           node.vm.provider "virtualbox" do |vb|
  #                  vb.memory = "256"
  #                  vb.cpus = 1
  #           end
  #
  #           node.vm.provision "shell" do |s|
  #             s.inline = <<-SHELL
  #             sudo echo "HOSTNAME=bastion" >> /etc/sysconfig/network
  #             hostname bastion
  #             /etc/init.d/network restart
  #             SHELL
  #           end
  #
  #           node.vm.provision "shell", inline: <<-SHELL
  #               sudo /vagrant/scripts/bastion-vagrant-provision.sh
  #           SHELL
  # end

end
