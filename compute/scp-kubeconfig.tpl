scp -i ${private_key_path} \
-o StrictHostKeyChecking=no \
-o UserKnownHostsFile=/dev/null \
-q ubuntu@${node_ip}:/etc/rancher/k3s/k3s.yaml ${k3s_path}k3s-${node_name}.yaml && \
sed -i .bak 's/127.0.0.1/${node_ip}/' ${k3s_path}k3s-${node_name}.yaml
