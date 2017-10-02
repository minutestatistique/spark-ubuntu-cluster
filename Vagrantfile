# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version">= 1.5.0"

ipAdrPrefix = "192.168.100.10"
memTot = 30000
numNodes = 5
memory = memTot/numNodes
cpuCap = 100/numNodes

Vagrant.configure(2) do |config|
	r = numNodes..1
	(r.first).downto(r.last).each do |i|
		config.vm.define "node-#{i}" do |node|
			#node.vm.box = "hashicorp/precise64"
			node.vm.box = "box/precise64.box"
			node.vm.provider "virtualbox" do |v|
				v.name = "spark-node#{i}"
				v.customize ["modifyvm", :id, "--cpuexecutioncap", cpuCap]
				v.customize ["modifyvm", :id, "--memory", memory.to_s]
				v.customize ["modifyvm", :id, "--usb", "off"]
				v.customize ["modifyvm", :id, "--usbehci", "off"]
			end
			node.vm.network "private_network", ip: "#{ipAdrPrefix}#{i}"
			node.vm.hostname = "spark-node#{i}"
			node.vm.provision "shell" do |s|
				s.path = "./scripts/bootstrap.sh"
				s.args = "#{i} #{numNodes} #{ipAdrPrefix}"
				s.privileged = false
			end
		end
	end
end
