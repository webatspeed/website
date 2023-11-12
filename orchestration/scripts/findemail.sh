#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "USAGE: ./findemail.sh <email>"
    exit 1
fi

echo "Current context is $(kubectl config current-context)."
while true; do
    read -p "Do you wish to search for $1 (y/n)? " yn
    case $yn in
        [Yy]* )
          MONGO_USERNAME=$(kubectl get secret mongo-credentials --template={{.data.username}}|base64 --decode);
          MONGO_PASSWORD=$(kubectl get secret mongo-credentials --template={{.data.password}}|base64 --decode);
          MONGO_QUERY="db.subscription.find({\"email\": \"$1\"});"
          MONGO_CONNECTION="mongodb://$MONGO_USERNAME:$MONGO_PASSWORD@localhost:27017/subscription?authSource=admin"
          MONGO_SEARCH="mongosh --eval '$MONGO_QUERY' $MONGO_CONNECTION";
          kubectl exec deployment/mongodb -- sh -c "$MONGO_SEARCH";
          break;;
        [Nn]* )
          exit;;
        * )
          echo "Please answer y or n.";;
    esac
done
