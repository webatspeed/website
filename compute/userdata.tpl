#!/bin/bash
sudo hostnamectl set-hostname ${node_name} && \
curl -sfL https://get.k3s.io | sh -s - server \
--datastore-endpoint="mysql://${db_user}:${db_pass}@tcp(${db_endpoint})/${db_name}" \
--write-kubeconfig-mode 644 \
--tls-san=$(curl http://169.254.169.254/latest/meta-data/public-ipv4) \
--token="${token}"
