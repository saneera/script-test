#!/bin/bash

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

ZOOKEEPER_NODE_COUNT=$(getProperty "zookeeper.replicas")
ZOOKEEPER_HEALTHCHECK_DELAY=$(getProperty "zookeeper.healthcheck.delay")
ZOOKEEPER_HEALTHCHECK_TIMEOUT=$(getProperty "zookeeper.healthcheck.timeout")
ZOOKEEPER_VOLUME_CAPACITY=$(getProperty "zookeeper.volume.capacity")

KAFKA_NODE_COUNT=$(getProperty "kafka.replicas")
KAFKA_HEALTHCHECK_DELAY=$(getProperty "kafka.healthcheck.delay")
KAFKA_HEALTHCHECK_TIMEOUT=$(getProperty "kafka.healthcheck.timeout")
KAFKA_VOLUME_CAPACITY=$(getProperty "kafka.volume.capacity")

KAFKA_DEFAULT_REPLICATION_FACTOR=$(getProperty "kafka.default.replication.factor")
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=$(getProperty "kafka.offset.topic.replication.factor")
KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=$(getProperty "kafka.transaction.state.replication.factor")

VALID_ISSUER_URL=$(getProperty "valid_issuer_url")
JWKS_ENDPOINT=$(getProperty "jwks_endpoint")
KAFKA_CLIENT_ID=$(getProperty "kafka.client.id")
KAFKA_CLIENT_SECRET=$(getProperty "kafka.client.secret")
KAFKA_SECRET=$(getProperty "kafka.secret")
CA_TRUST=$(getProperty "ca.truststore")
CA_CERT=$(getProperty "ca.cert")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# ensure to be on the right namespace
oc project $NAMESPACE 2> /dev/null || oc new-project $NAMESPACE

export HISTCONTROL=ignorespace
echo $INSTALL_TYPE
kubectl create secret generic $KAFKA_SECRET -n $NAMESPACE --from-literal=secret=$KAFKA_CLIENT_SECRET
kubectl create secret generic $CA_TRUST --from-file=$CA_CERT -n $NAMESPACE

echo "Creating template in openshift for specific project to install kafka cluster - Start"
oc create -f $DIR/resources/kafka-template.yaml -n $NAMESPACE
echo "Created template in openshift for specific project to install kafka cluster - Done"

oc new-app strimzi-persistent -n $NAMESPACE \
  -p CLUSTER_NAME=$CLUSTER_NAME\
  -p ZOOKEEPER_NODE_COUNT=$ZOOKEEPER_NODE_COUNT\
  -p ZOOKEEPER_HEALTHCHECK_DELAY=$ZOOKEEPER_HEALTHCHECK_DELAY\
  -p ZOOKEEPER_HEALTHCHECK_TIMEOUT=$ZOOKEEPER_HEALTHCHECK_TIMEOUT\
  -p ZOOKEEPER_VOLUME_CAPACITY=$ZOOKEEPER_VOLUME_CAPACITY\
  -p KAFKA_NODE_COUNT=$KAFKA_NODE_COUNT\
  -p KAFKA_HEALTHCHECK_DELAY=$KAFKA_HEALTHCHECK_DELAY\
  -p KAFKA_HEALTHCHECK_TIMEOUT=$KAFKA_HEALTHCHECK_TIMEOUT\
  -p KAFKA_VOLUME_CAPACITY=$KAFKA_VOLUME_CAPACITY\
  -p KAFKA_DEFAULT_REPLICATION_FACTOR=$KAFKA_DEFAULT_REPLICATION_FACTOR\
  -p KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=$KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR\
  -p KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=$KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR\
  -p OAUTH_SERVER=$OAUTH_SERVER\
  -p KAFKA_CLIENT_ID=$KAFKA_CLIENT_ID\
  -p KAFKA_SECRET=$KAFKA_SECRET\
  -p CA_TRUST=$CA_TRUST\
  -p CA_CERT=$CA_CERT\
  -p VALID_ISSUER_URL=$VALID_ISSUER_URL\
  -p JWKS_ENDPOINT=$JWKS_ENDPOINT

# delay for allowing cluster operator to create the Zookeeper statefulset
sleep 5

zkReplicas=$(oc get kafka $CLUSTER_NAME -o jsonpath="{.spec.zookeeper.replicas}" -n $NAMESPACE)
echo "Waiting for Zookeeper cluster to be ready..."
readyReplicas="0"
while [ "$readyReplicas" != "$zkReplicas" ]
do
    sleep 3
    readyReplicas=$(oc get statefulsets $CLUSTER_NAME-zookeeper -o jsonpath="{.status.readyReplicas}" -n $NAMESPACE)
done
echo "...Zookeeper cluster ready"


# delay for allowing cluster operator to create the Kafka statefulset
sleep 5

kReplicas=$(oc get kafka $CLUSTER_NAME -o jsonpath="{.spec.kafka.replicas}" -n $NAMESPACE)
echo "Waiting for Kafka cluster to be ready..."
readyReplicas="0"
while [ "$readyReplicas" != "$kReplicas" ]
do
    sleep 3
    readyReplicas=$(oc get statefulsets $CLUSTER_NAME-kafka -o jsonpath="{.status.readyReplicas}" -n $NAMESPACE)
done
echo "...Kafka cluster ready"

echo "Waiting for entity operator to be ready..."
oc rollout status deployment/$CLUSTER_NAME-entity-operator -w -n $NAMESPACE
echo "...entity operator ready"
