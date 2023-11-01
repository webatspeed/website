#!/bin/sh

echo "Current context is $(kubectl config current-context)."
while true; do
    read -p "Do you wish to distribute the newsletter (y/n)? " yn
    case $yn in
        [Yy]* )
          POD=$(kubectl get pods -l app=frontend -o jsonpath="{.items[0].metadata.name}");
          kubectl exec $POD -- wget -q --spider --post-data '' http://subscription-service:8080/v1/subscription/distribute;
          break;;
        [Nn]* )
          exit;;
        * )
          echo "Please answer y or n.";;
    esac
done
