# ensure to be on the right namespace
kubectl namespace $NAMESPACE 2> /dev/null || kubectl create namespace $NAMESPACE

kubectl create secret generic $KAFKA_CLIENT_SECRET -n $NAMESPACE --from-literal=secret=$BROKER_SECRET
kubectl create secret generic $CA_TRUST --from-file=./ca.crt -n $NAMESPACE

echo "Creating template in openshift for specific project to install kafka cluster_name - Start"
kubectl create -f $DIR/resources/kafka-config.yaml -n $NAMESPACE
echo "Created template in openshift for specific project to install kafka cluster_name - Done"

# delay for allowing cluster_name operator to create the Zookeeper statefulset
sleep 5

zkReplicas=$(kubectl get kafka $CLUSTER_NAME -o jsonpath="{.spec.zookeeper.replicas}" -n $NAMESPACE)
echo "Waiting for Zookeeper cluster_name to be ready..."
readyReplicas="0"
while [ "$readyReplicas" != "$zkReplicas" ]
do
    sleep 3
    readyReplicas=$(kubectl get statefulsets $CLUSTER_NAME-zookeeper -o jsonpath="{.status.readyReplicas}" -n $NAMESPACE)
done
echo "...Zookeeper cluster_name ready"


# delay for allowing cluster_name operator to create the Kafka statefulset
sleep 5

kReplicas=$(kubectl get kafka $CLUSTER_NAME -o jsonpath="{.spec.kafka.replicas}" -n $NAMESPACE)
echo "Waiting for Kafka cluster_name to be ready..."
readyReplicas="0"
while [ "$readyReplicas" != "$kReplicas" ]
do
    sleep 3
    readyReplicas=$(kubectl get statefulsets $CLUSTER_NAME-kafka -o jsonpath="{.status.readyReplicas}" -n $NAMESPACE)
done
echo "...Kafka cluster_name ready"

echo "Waiting for entity operator to be ready..."
kubectl rollout status deployment/$CLUSTER_NAME-entity-operator -w -n $NAMESPACE
echo "...entity operator ready"