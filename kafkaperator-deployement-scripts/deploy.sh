#!/bin/bash


TILLER_NAMESPACE=${TILLER_NAMESPACE:-tiller}
echo "TILLER_NAMESPACE=" $TILLER_NAMESPACE
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-strimzi-operator}
echo "OPERATOR_NAMESPACE=" $OPERATOR_NAMESPACE

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

$DIR/01-install-helm.sh
$DIR/02-install-tiller.sh
$DIR/03-deploy-kafka-operator.sh