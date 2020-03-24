#!/bin/bash

TILLER_NAMESPACE=${TILLER_NAMESPACE:-tiller}
echo "TILLER_NAMESPACE=" $TILLER_NAMESPACE
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-strimzi-operator}
echo "OPERATOR_NAMESPACE=" $OPERATOR_NAMESPACE

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo "cp helm to gloal path "
cp helm-v2.9.0/helm /usr/local/bin
cp helm-v2.9.0/helm /usr/bin

chmod +x /usr/local/bin/helm
chmod +x /usr/bin/helm
