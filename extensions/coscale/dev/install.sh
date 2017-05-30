docker-username=$1
docker-password=$2

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh 

chmod 700 get_helm.sh 

./get_helm.sh

helm init

kubectl create secret docker-registry coscale-registry \
    --docker-server=docker.coscale.com \
    --docker-username=$docker-username \
    --docker-password=$docker-password \
    --docker-email='dummy@coscale.com' \
    --namespace=default

helm install --name CoScale --wait --timeout 1800 coscale-data-services-0.1.0.tgz


