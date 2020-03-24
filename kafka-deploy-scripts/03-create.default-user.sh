#!/bin/bash

PROPERTY_FILE=config.properties

function getProperty {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE
}

NAMESPACE=$(getProperty "namespace")
CLUSTER=$(getProperty "cluster.name")
TOPIC_NAME=$(getProperty "topic.name")
DEFAULT_USER=$(getProperty "default.user")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# create Kafka topics
eval "echo \"$(cat $DIR/kafka/kafka-user.yaml)\""  | oc apply -f - -n $NAMESPACE


