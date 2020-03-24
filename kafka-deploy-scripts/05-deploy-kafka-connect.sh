#!/bin/bash

set +x

PROPERTY_FILE=config-$INSTALLATION_TYPE.properties

function getProperty {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE
}

# NAMESPACE=$(getProperty "namespace")
# CLUSTER_NAME=$(getProperty "cluster.name")
BOOTSTRAP_SERVER="${CLUSTER_NAME}-kafka-bootstrap:9093"
SECRET_NAME="${CLUSTER_NAME}-cluster-ca-cert"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# ensure to be on the right namespace
oc project $NAMESPACE 2> /dev/null || oc new-project $NAMESPACE

echo "Applying kafka connect resources"

cat $DIR/resources/kafka-connect.yaml \
  | sed "s/name: .*/name: $CLUSTER_NAME/" \
  | sed "s/secretName: .*/secretName: $SECRET_NAME/" \
  | sed "s/bootstrapServers: .*/bootstrapServers: $BOOTSTRAP_SERVER/" \
  | kubectl apply -f - -n $NAMESPACE


