#!/bin/bash
set +x

PROPERTY_FILE=config.properties

function getProperty {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE
}

NAMESPACE=$(getProperty "namespace")
CLUSTER_NAME=$(getProperty "cluster_name.name")
BROKER_SECRET=$(getProperty "broker.secret")
OAUTH_SERVER=$(getProperty "oauth.server")
KAFKA_CLIENT_ID=$(getProperty "kafka.client.id")
KAFKA_CLIENT_SECRET=$(getProperty "client.secret")
CA_TRUST=$(getProperty "ca.truststore")
CA_CERT=$(getProperty "ca.cert")

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


echo "NAMESPACE="$NAMESPACE
echo "CLUSTER_NAME="$CLUSTER_NAME
echo "BROKER_SECRET="$BROKER_SECRET
echo "OAUTH_SERVER="$OAUTH_SERVER
echo "KAFKA_CLIENT_ID="$KAFKA_CLIENT_ID
echo "KAFKA_CLIENT_SECRET="$KAFKA_CLIENT_SECRET
echo "CA_TRUST="$CA_TRUST
echo "CA_CERT="$CA_CERT

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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"



