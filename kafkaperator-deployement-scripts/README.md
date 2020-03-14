### Deploy Strimzi operator using helm
This document helps you to install and uninstall Strimzi operator on OpenShift environment, configured to 
install strimzi operator on global namespace  

#### Step 01 : set environment variable
```
export TILLER_NAMESPACE=tiller
export OPERATOR_NAMESPACE=strimzi-operator
```

#### Step 02 : run deploy.sh

```
./deploy.sh
```

### Uninstall using helm
```
./undeploy.sh
```