#!/bin/bash
set +x

export INSTALLATION_TYPE=${INSTALLATION_TYPE:="keycloak"}
export NAMESPACE=${NAMESPACE:="kafka-test"}
export CLUSTER_NAME=${CLUSTER_NAME:="my-cluster"}


echo "Installation type ?"
echo "  Select which installation type do you want to install ( option 1: keycloak, option 2: adfs)"
select yn in "1" "2"; do
case $yn in
1) export INSTALLATION_TYPE=keycloak; break;;
2) export INSTALLATION_TYPE=adfs; break;;
*) echo "Please select 1 or 2.";;
esac
done

read -rp "Namespace to use: ($NAMESPACE): " choice;
if [ "$choice" != "" ] ; then
		export NAMESPACE="$choice";
fi

read -rp "Cluster name to use: ($CLUSTER_NAME): " choice;
if [ "$choice" != "" ] ; then
		export CLUSTER_NAME="$choice";
fi

PROPERTY_FILE=config-$INSTALLATION_TYPE.properties

function getProperty {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE
}

# NAMESPACE=$(getProperty "namespace")
# CLUSTER_NAME=$(getProperty "cluster.name")

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

TOPIC_NAME=$(getProperty "topic.name")

echo "NAMESPACE="$NAMESPACE
echo "CLUSTER_NAME="$CLUSTER_NAME

echo "ZOOKEEPER_NODE_COUNT="$ZOOKEEPER_NODE_COUNT
echo "ZOOKEEPER_HEALTHCHECK_DELAY="$ZOOKEEPER_HEALTHCHECK_DELAY
echo "ZOOKEEPER_HEALTHCHECK_TIMEOUT="$ZOOKEEPER_HEALTHCHECK_TIMEOUT
echo "ZOOKEEPER_VOLUME_CAPACITY="$ZOOKEEPER_VOLUME_CAPACITY

echo "KAFKA_NODE_COUNT="$KAFKA_NODE_COUNT
echo "KAFKA_HEALTHCHECK_DELAY="$KAFKA_HEALTHCHECK_DELAY
echo "KAFKA_HEALTHCHECK_TIMEOUT="$KAFKA_HEALTHCHECK_TIMEOUT
echo "KAFKA_VOLUME_CAPACITY="$KAFKA_VOLUME_CAPACITY

echo "KAFKA_DEFAULT_REPLICATION_FACTOR="$KAFKA_DEFAULT_REPLICATION_FACTOR
echo "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR="$KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR
echo "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR="$KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR

oc project $NAMESPACE 2> /dev/null || oc new-project $NAMESPACE

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo "Current directory" $DIR

$DIR/01-deploy-kafka.sh
$DIR/02-create.default-topic.sh
$DIR/03-create.default-user.sh
$DIR/04-deploy-kafka-bridge.sh
$DIR/05-deploy-kafka-connect.sh

