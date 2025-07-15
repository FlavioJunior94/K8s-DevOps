Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  master_shared_folders = [
    { src: "ansible-docker", dest: "/root/ansible-docker" },
    { src: "ansible-k8s", dest: "/root/ansible-k8s" }
  ]

  nodes = [
    { :hostname => "k8s-master", :ip => "192.168.6.10" },
    { :hostname => "k8s-worker1", :ip => "192.168.6.11" },
    { :hostname => "k8s-worker2", :ip => "192.168.6.12" }
  ]

  config.vm.boot_timeout = 600

  nodes.each do |node|
    config.vm.define node[:hostname] do |n|
      n.vm.hostname = node[:hostname]
      n.vm.network "private_network", ip: node[:ip], nic_type: "82540EM"



      n.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end

      if node[:hostname] == "k8s-master"
        master_shared_folders.each do |folder|
          n.vm.synced_folder folder[:src], folder[:dest]
        end

        n.vm.provision "shell", path: "bootstrap.sh"

        n.vm.provision "shell", path: "bootstrap-master.sh", run: "always"
      else
        n.vm.provision "shell", path: "bootstrap.sh"
      end
    end
  end
end
