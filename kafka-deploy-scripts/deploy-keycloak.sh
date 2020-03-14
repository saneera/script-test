#!/bin/bash
set +x

# create CA key
openssl genrsa -out ca.key 2048

# create CA certificate
openssl req -x509 -new -nodes -sha256 -days 3650 -subj "/CN=digitaldatastorage.com"   -key ca.key -out ca.crt

# create keycloak server private key
openssl genrsa -out keycloak.key 2048

cp /etc/pki/tls/openssl.cnf ssl.cnf
cat >> ssl.cnf << EOF
 [ SAN ]
 basicConstraints = CA:FALSE
 keyUsage = digitalSignature, keyEncipherment
 subjectAltName = DNS:keycloak.keycloak, DNS:keycloak.digitaldatastorage.com
EOF

openssl req -new -sha256  -key keycloak.key  -subj "/CN=keycloak"  -reqexts SAN  -config ssl.cnf  -out keycloak.csr

openssl x509 -req -extfile ssl.cnf -extensions SAN -in keycloak.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out keycloak.crt -days 3650 -sha256

kubectl create ns keycloak
kubectl create secret tls tls-keys -n keycloak  --cert=./keycloak.crt --key=./keycloak.key
kubectl apply -f resources/keycloak.yaml -n keycloak

