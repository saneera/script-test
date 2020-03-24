#!/bin/bash
set +x

PROPERTY_FILE=config.properties

function getProperty {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE
}

NAMESPACE=$(getProperty "namespace")
CLUSTER_NAME=$(getProperty "cluster.name")
BRIDGE_NAME="${CLUSTER_NAME}"
BOOTSTRAP_SERVER="${CLUSTER_NAME}-kafka-bootstrap:9092"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# ensure to be on the right namespace
oc project $NAMESPACE 2> /dev/null || oc new-project $NAMESPACE

echo "Applying bridge resources"

cat $DIR/resources/kafka-bridge.yaml \
  | sed "s/name: .*/name: $BRIDGE_NAME/" \
  | sed "s/bootstrapServers: .*/bootstrapServers: $BOOTSTRAP_SERVER/" \
  | kubectl apply -f - -n $NAMESPACE


