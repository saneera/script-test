#!/bin/bash
set +x

PROPERTY_FILE=config.properties

function getProperty {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE
}

NAMESPACE=$(getProperty "namespace")
CLUSTER=$(getProperty "cluster.name")
TOPIC_NAME=$(getProperty "topic.name")

echo "NAMESPACE="$NAMESPACE
echo "CLUSTER="$CLUSTER

kubectl namespace $NAMESPACE 2> /dev/null || kubectl create namespace $NAMESPACE

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo "Current directory" $DIR

$DIR/01-deploy-kafka.sh
#$DIR/02-create.default-topic.sh

