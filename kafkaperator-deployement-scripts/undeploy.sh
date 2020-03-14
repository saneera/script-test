#!/bin/bash

TILLER_NAMESPACE=${TILLER_NAMESPACE:-tiller}
echo "TILLER_NAMESPACE=" $TILLER_NAMESPACE
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-strimzi-operator}
echo "OPERATOR_NAMESPACE=" $OPERATOR_NAMESPACE

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

helm del --purge $OPERATOR_NAMESPACE

# delete namespace itself
oc delete namespace $TILLER_NAMESPACE
oc delete namespace $OPERATOR_NAMESPACE
