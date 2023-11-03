#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "USAGE: ./mongodump.sh /directory/to/save"
    exit 1
fi

if [ -d "$1" ]; then
  FILENAME=mongodb-archive-$(date '+%Y%m%d%H%M%S').gz
  TARGET_FILE=${1%/}/$FILENAME
  echo "About to save dump in $TARGET_FILE ..."
else
  echo "ERROR: $1 is not a directory."
  exit 1
fi

echo "Current context is $(kubectl config current-context)."
while true; do
    read -p "Do you wish to dump MongoDB (y/n)? " yn
    case $yn in
        [Yy]* )
          TMP_FILE=/tmp/$FILENAME
          POD=$(kubectl get pods -l app=mongodb -o jsonpath="{.items[0].metadata.name}");
          MONGO_USERNAME=$(kubectl get secret mongo-credentials --template={{.data.username}}|base64 --decode);
          MONGO_PASSWORD=$(kubectl get secret mongo-credentials --template={{.data.password}}|base64 --decode);
          MONGO_DUMP="mongodump --gzip --archive=$TMP_FILE mongodb://$MONGO_USERNAME:$MONGO_PASSWORD@localhost:27017/subscription?authSource=admin";
          kubectl exec $POD -- sh -c "$MONGO_DUMP";
          kubectl cp $POD:$TMP_FILE $TARGET_FILE;
          break;;
        [Nn]* )
          exit;;
        * )
          echo "Please answer y or n.";;
    esac
done
