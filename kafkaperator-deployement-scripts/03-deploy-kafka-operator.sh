#!/bin/bash

TILLER_NAMESPACE=${TILLER_NAMESPACE:-tiller}
echo "TILLER_NAMESPACE=" $TILLER_NAMESPACE
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-strimzi-operator}
echo "OPERATOR_NAMESPACE=" $OPERATOR_NAMESPACE
export TILLER_NAMESPACE=tiller

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

oc project $OPERATOR_NAMESPACE 2> /dev/null || oc new-project $OPERATOR_NAMESPACE

helm install $DIR/strimzi-kafka-operator --name $OPERATOR_NAMESPACE --namespace $OPERATOR_NAMESPACE

