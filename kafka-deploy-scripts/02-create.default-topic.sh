#!/bin/bash

PROPERTY_FILE=config.properties

function getProperty {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE
}

NAMESPACE=$(getProperty "namespace")
CLUSTER=$(getProperty "cluster.name")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cat $DIR/resources/kafka-topics.yaml \
  | sed "s/cluster: .*/cluster: $CLUSTER/" \
  | sed "s/namespace: .*/namespace: $NAMESPACE/" \
  | kubectl apply -f - -n $NAMESPACE


