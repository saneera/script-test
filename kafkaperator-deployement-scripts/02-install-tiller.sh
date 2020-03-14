#!/bin/bash

TILLER_NAMESPACE=${TILLER_NAMESPACE:-tiller}
echo "TILLER_NAMESPACE=" $TILLER_NAMESPACE
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-strimzi-operator}
echo "OPERATOR_NAMESPACE=" $OPERATOR_NAMESPACE

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

oc project $TILLER_NAMESPACE 2> /dev/null || oc new-project $TILLER_NAMESPACE
export TILLER_NAMESPACE=tiller

cd ..
rm -rf linux-amd64

sleep 5

cp $DIR/tiller/tiller-template.yaml  $DIR/tiller/$TILLER_NAMESPACE-tiller-template.yaml

oc process -f $DIR/tiller/$TILLER_NAMESPACE-tiller-template.yaml -p TILLER_NAMESPACE="${TILLER_NAMESPACE}" -p HELM_VERSION=v2.9.0 | oc create -f -

echo "Waiting for tiller to be ready..."
oc rollout status deployment tiller
sleep 5
echo "...tiller ready"

echo "Add cluster admin role to tiller service account.."
oc create clusterrolebinding tiller-binding --clusterrole=cluster-admin --user=system:serviceaccount:tiller:tiller
echo "Added cluster admin role to tiller service account.."

helm version

rm $DIR/tiller/$TILLER_NAMESPACE-tiller-template.yaml

