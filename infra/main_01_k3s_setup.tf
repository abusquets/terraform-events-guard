resource "null_resource" "k3s_setup" {
  # count = var.enable_k3s_setup ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.my_private_key)
    host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
  }

  provisioner "file" {
    source      = "data/setup_k3s.sh"
    destination = "setup_k3s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh ~/setup_k3s.sh ${aws_lightsail_static_ip.events_guard_static_ip.ip_address} ${var.k3s_token}"
    ]
  }
  depends_on = [aws_lightsail_instance.docker_server]

}

resource "null_resource" "get_kubeconfig" {
  # count = var.enable_k3s_setup ? 1 : 0

  provisioner local-exec {
    command = "scp -o StrictHostKeyChecking=no -i ${var.my_private_key} ec2-user@${aws_lightsail_static_ip.events_guard_static_ip.ip_address}:/etc/rancher/k3s/k3s.yaml tmp/k3s.yaml"
  }

}


resource "null_resource" "k3s_setup_kubectl_namespace" {
  count = var.enable_k3s_setup ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.my_private_key)
    host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
  }

  provisioner "file" {
    source      = "data/k3s/namespace.yaml"
    destination = "namespace.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f namespace.yaml",
    ]
  }
  depends_on = [aws_lightsail_instance.docker_server]
}


resource "null_resource" "k3s_setup_kubectl_hello_world1" {
  # count = var.enable_k3s_setup ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.my_private_key)
    host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
  }

  provisioner "file" {
    source      = "data/k3s/hello-world-deployment.yaml"
    destination = "hello-world-deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f hello-world-deployment.yaml",
    ]
  }
  depends_on = [aws_lightsail_instance.docker_server]
}


resource "null_resource" "k3s_setup_kubectl_caddy_config1" {
  # count = var.enable_k3s_setup ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.my_private_key)
    host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
  }

  provisioner "file" {
    content  = templatefile("data/k3s/caddy-config.yaml.tftpl", { issuer_email = var.issuer_email, domain_name = var.domain_name })
    destination = "caddy-config.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f caddy-config.yaml",
    ]
  }
  depends_on = [aws_lightsail_instance.docker_server]
}


resource "null_resource" "k3s_setup_kubectl_caddy_deployment" {
  # count = var.enable_k3s_setup ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.my_private_key)
    host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
  }

  provisioner "file" {
    source      = "data/k3s/caddy-deployment.yaml"
    destination = "caddy-deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f caddy-deployment.yaml",
    ]
  }
  depends_on = [aws_lightsail_instance.docker_server]
}




# resource "null_resource" "k3s_setup_kubectl_issuer" {
#   count = var.enable_k3s_setup ? 1 : 0

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file(var.my_private_key)
#     host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
#   }

#   provisioner "file" {
#     content  = templatefile("data/k3s/issuer.yaml.tftpl", { issuer_email = var.issuer_email })
#     destination = "issuer.yaml"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "kubectl apply -f issuer.yaml",
#     ]
#   }
#   depends_on = [aws_lightsail_instance.docker_server]
# }

# resource "null_resource" "k3s_setup_kubectl_app" {
#   count = var.enable_k3s_setup ? 1 : 0

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file(var.my_private_key)
#     host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
#   }

#   provisioner "file" {
#     source      = "data/k3s/app.yaml"
#     destination = "app.yaml"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "kubectl apply -f app.yaml",
#     ]
#   }
#   depends_on = [aws_lightsail_instance.docker_server]
# }


# resource "null_resource" "k3s_setup_kubectl_ingress" {
#   count = var.enable_k3s_setup ? 1 : 0

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file(var.my_private_key)
#     host         = aws_lightsail_static_ip.events_guard_static_ip.ip_address
#   }

#   provisioner "file" {
#     content  = templatefile("data/k3s/ingress.yaml.tftpl", { domain_name = var.domain_name })
#     destination = "ingress.yaml"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "kubectl apply -f ingress.yaml"
#     ]
#   }

#   depends_on = [aws_lightsail_instance.docker_server]

# }