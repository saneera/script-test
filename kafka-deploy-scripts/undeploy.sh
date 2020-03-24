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

# delete Kafka users and topics
kubectl delete kafkauser -ns $NAMESPACE
kubectl delete kafkatopic -ns $NAMESPACE

# delete pvc is attched
kubectl delete pvc --all -n $NAMESPACE
# delete Kafka cluster
kubectl delete kafka $CLUSTER -ns $NAMESPACE

# delete namespace itself
kubectl delete namespace $NAMESPACE
