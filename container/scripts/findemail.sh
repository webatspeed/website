#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "USAGE: ./findemail.sh <email>"
    exit 1
fi

MONGO_USERNAME=$(aws ecs describe-task-definition \
 --task-definition mongodb | \
 jq -r '.taskDefinition.containerDefinitions[] | select(.name == "mongodb") | .environment | .[] | select(.name == "MONGO_INITDB_ROOT_USERNAME") | .value')

MONGO_PASSWORD=$(aws ecs describe-task-definition \
 --task-definition mongodb | \
 jq -r '.taskDefinition.containerDefinitions[] | select(.name == "mongodb") | .environment | .[] | select(.name == "MONGO_INITDB_ROOT_PASSWORD") | .value')

MONGO_TASK=$(aws ecs list-tasks \
 --cluster webatspeed-cluster \
 --service-name mongodb \
 --query "taskArns" | \
 jq -r '.[0] | split("/")[-1]')

MONGO_QUERY="db.subscription.find({\"email\": \\\"$1\\\"});"
MONGO_CONNECTION="mongodb://$MONGO_USERNAME:$MONGO_PASSWORD@localhost:27017/subscription?authSource=admin"
MONGO_SEARCH="mongosh --eval '$MONGO_QUERY' $MONGO_CONNECTION";

aws ecs execute-command \
 --cluster webatspeed-cluster \
 --task $MONGO_TASK \
 --container mongodb \
 --interactive \
 --command "/bin/bash -c \"$MONGO_SEARCH\"";
