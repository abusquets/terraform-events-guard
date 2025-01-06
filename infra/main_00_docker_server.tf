resource "aws_lightsail_instance" "docker_server" {
  name              = "${var.instance_name}-05"
  availability_zone = "${var.aws_region}a"
  blueprint_id      = var.instance_blueprint_id
  bundle_id         = var.instance_bundle_id
  key_pair_name     = var.instance_key_pair_name

  user_data = <<-EOT
    #!/bin/bash

    # System update
    sudo dnf update -y

    sudo dnf install -y docker iptables iptables-services git
    sudo systemctl start docker
    sudo systemctl enable docker

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Generate MongoDB keyfile
    sudo mkdir -p /opt/docker-app
    sudo openssl rand -base64 756 > /opt/docker-app/mongo-keyfile
    sudo chmod 600 /opt/docker-app/mongo-keyfile
    sudo chown 999:999 /opt/docker-app/mongo-keyfile

    # Configure Docker Compose
    cat <<EOF | sudo tee /opt/docker-app/docker-compose.yaml
    version: '3.8'

    services:
      redis:
        image: redis:latest
        container_name: redis
        ports:
          - "6379:6379"
        volumes:
          - redis_data:/data
        command: ["redis-server", "--appendonly", "yes", "--appendfsync", "everysec"]
        restart: always
        environment:
          - REDIS_PASSWORD=${var.redis_password}

      mongo1:
        image: mongo:latest
        container_name: mongo1
        command: ["--replSet", "rs0", "--bind_ip_all", "--port", "27017", "--keyFile", "/etc/mongo-keyfile"]
        healthcheck:
          test: echo "try { rs.status() } catch (err) { rs.initiate({_id:'rs0',members:[{_id:0,host:'mongo1:27017'},{_id:1,host:'mongo2:27017'}]}) }" | mongosh --port 27017 -u admin -p "${var.mongodb_password}" --authenticationDatabase admin --quiet
          interval: 5s
          timeout: 30s
          start_period: 0s
          start_interval: 1s
          retries: 30
        volumes:
          - mongo1_data:/data/db
          - ./mongo-keyfile:/etc/mongo-keyfile:ro
        environment:
          - MONGO_INITDB_ROOT_USERNAME=admin
          - MONGO_INITDB_ROOT_PASSWORD=${var.mongodb_password}

      mongo2:
        image: mongo:latest
        container_name: mongo2
        volumes:
          - mongo2_data:/data/db
          - ./mongo-keyfile:/etc/mongo-keyfile:ro
        command: ["--replSet", "rs0", "--bind_ip_all", "--port", "27017", "--keyFile", "/etc/mongo-keyfile"]
        healthcheck:
          test: ["CMD", "mongo", "--eval", "db.adminCommand('ping')"]
          interval: 30s
          retries: 5
        environment:
          - MONGO_INITDB_ROOT_USERNAME=admin
          - MONGO_INITDB_ROOT_PASSWORD=${var.mongodb_password}

    volumes:
      redis_data:
      mongo1_data:
      mongo2_data:
    EOF

    # Start docker-compose
    sudo docker-compose -f /opt/docker-app/docker-compose.yaml up -d

  EOT

}

resource "aws_lightsail_static_ip_attachment" "static_ip_attachment" {
  static_ip_name = aws_lightsail_static_ip.events_guard_static_ip.name
  instance_name  = aws_lightsail_instance.docker_server.name

  depends_on = [aws_lightsail_instance.docker_server]

}

resource "aws_lightsail_instance_public_ports" "docker_server_firewall" {
  instance_name = aws_lightsail_instance.docker_server.name

  port_info {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  port_info {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  port_info {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  depends_on = [aws_lightsail_instance.docker_server]

}


