#!/bin/bash -e

DOCKER_USERNAME=${1}
DOCKER_PASSWORD=${2}

#Getting helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh -sS

chmod 700 get_helm.sh 

./get_helm.sh

helm init

kubectl create secret docker-registry coscale-registry \
    --docker-server=docker.coscale.com \
    --docker-username=$DOCKER_USERNAME \
    --docker-password=$DOCKER_PASSWORD \
    --docker-email='dummy@coscale.com' \
    --namespace=default

#Downloading charts
curl https://raw.githubusercontent.com/marrobi/coscale-acs-extension/master/scripts/coscale-data-services-0.1.0.tgz -o coscale-data-services-0.1.0.tgz -sS
curl https://raw.githubusercontent.com/marrobi/coscale-acs-extension/master/scripts/coscale-app-0.1.0.tgz -o coscale-app-0.1.0.tgz -sS

helm install --name CoScaleDataServices --wait --timeout 1800 coscale-data-services-0.1.0.tgz

# Initialise the keyspace in Cassandra
cat << EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cs-init
spec:
  template:
    metadata:
      labels:
        app: cs-init
    spec:
      containers:
      - name: init
        image: gcr.io/google-samples/cassandra:v11
        imagePullPolicy: Always
        command: [ "/bin/bash", "-c" ]
        args: [ "/bin/echo \"create keyspace coscale with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };\" | /usr/bin/cqlsh cassandra" ]
      restartPolicy: Never
EOF

helm install --name CoScaleAppServices --wait --timeout 1800 coscale-app-0.1.0.tgz

API1=`kubectl get pods -l app=cs-api -o jsonpath='{.items[0].metadata.name}'`
kubectl exec $API1 python /opt/coscale/api/gen-superuser.py
kubectl exec $API1 /opt/coscale/agent-builder/agent-builder-standalone
