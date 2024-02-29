#!/bin/sh

if [ "$#" -ne 0 ]; then
    echo "USAGE: ./distribute.sh"
    exit 1
fi

FRONTEND_TASK=$(aws ecs list-tasks \
 --cluster webatspeed-cluster \
 --service-name frontend \
 --query "taskArns" | \
 jq -r '.[0] | split("/")[-1]')

DISTRIBUTE_CALL="wget -q --spider --post-data '' http://subscription.webatspeed.local:8080/v1/subscription/distribute";

aws ecs execute-command \
 --cluster webatspeed-cluster \
 --task $FRONTEND_TASK \
 --container frontend \
 --interactive \
 --command "sh -c \"$DISTRIBUTE_CALL\"";
