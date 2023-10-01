KAFKA_CONNECT_ENABLE = ENV['KAFKA_CONNECT_ENABLE']

Vagrant.configure("2") do |config|
  config.env.enable # Enable vagrant-env(.env)
  config.vm.box_check_update = false
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "shell", path: "scripts/init.sh", env: {
    "NODE_COUNT" => ENV['NODE_COUNT'],
    "NODE_PREFIX_IP" => ENV['NODE_PREFIX_IP'],
  }

  (1..ENV['NODE_COUNT'].to_i).each do |i|
    config.vm.define "kafka#{i}" do |config|
      config.vm.hostname = "kafka#{i}"
      config.vm.network "private_network", ip: "#{ENV['NODE_PREFIX_IP']}#{i}"

      if "#{ENV['ZOOKEEPER_ENABLE']}".downcase == 'true' then
        config.vm.provision "shell", path: "scripts/zookeeper.sh", env: {
          "ZOOKEEPER_VERSION" => ENV['ZOOKEEPER_VERSION'],
          "ZOOKEEPER_ID" => i,
        }
      end

      config.vm.provision "shell", path: "scripts/kafka.sh", env: {
        "IP" => "#{ENV['NODE_PREFIX_IP']}#{i}",
        "NODE_COUNT" => ENV['NODE_COUNT'],
        "NODE_PREFIX_IP" => ENV['NODE_PREFIX_IP'],
        "KAFKA_VERSION" => ENV['KAFKA_VERSION'],
        "KAFKA_ID" => i,
        "KAFKA_CONTROLLER" => ENV['KAFKA_CONTROLLER'],
      }
      
      if "#{ENV['CONNECT_ENABLE']}".downcase == 'true' then
        config.vm.provision "shell", path: "scripts/kafka-connect.sh", env: {
          "IP" => "#{ENV['NODE_PREFIX_IP']}#{i}",
          "CONNECT_DEBEZIUM_VERSION" => ENV['CONNECT_DEBEZIUM_VERSION'],
          "CONNECT_MYSQL_VERSION" => ENV['CONNECT_MYSQL_VERSION'],
          "CONNECT_JDBC_VERSION" => ENV['CONNECT_JDBC_VERSION'],
        }
      end
    end
  end
end