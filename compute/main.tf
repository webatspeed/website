data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "webatspeed_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "webatspeed_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "webatspeed_node" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  tags = {
    Name = "webatspeed_node-${random_id.webatspeed_node_id[count.index].dec}"
  }
  key_name               = aws_key_pair.webatspeed_auth.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  user_data = templatefile("${path.module}/install-k3s.tpl", {
    node_name   = "webatspeed-${random_id.webatspeed_node_id[count.index].dec}"
    db_endpoint = var.db_endpoint
    db_user     = var.db_user
    db_pass     = var.db_password
    db_name     = var.db_name
    token       = var.token
  })
  root_block_device {
    volume_size = var.vol_size
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
    }
    script = "${path.module}/wait-for-k3s.sh"
  }
  provisioner "local-exec" {
    command = templatefile("${path.module}/scp-kubeconfig.tpl",
      {
        node_ip          = self.public_ip
        k3s_path         = var.orch_config_path
        node_name        = self.tags.Name
        private_key_path = var.private_key_path
      }
    )
  }
}

resource "aws_lb_target_group_attachment" "webatspeed_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.webatspeed_node[count.index].id
  port             = var.tg_port
}
