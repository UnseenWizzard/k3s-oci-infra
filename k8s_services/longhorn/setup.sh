#!/bin/sh
echo "Setting up longhorn..."
helm repo add longhorn https://charts.longhorn.io
helm repo update

helm upgrade --atomic --install \
    longhorn longhorn/longhorn \
    --namespace longhorn-system \
    --create-namespace \
    --version 1.4.0

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


echo "Setting up longhorn UI and ingress (using public host $1)"
# Create longhorn UI user and ingress
USER=longhorn-admin
PASSWORD=$(openssl rand -base64 32) 
echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" > auth
echo "longhorn UI creds: ${USER}:${PASSWORD}"
echo "longhorn UI creds: ${USER}:${PASSWORD}" >> longhorn-ui.creds

kubectl -n longhorn-system create secret generic basic-auth --from-file=auth

tmpl=`cat "ui_ingress.yaml" | sed "s/{{HOSTNAME}}/$1/g"`

echo "$tmpl" | kubectl -n longhorn-system apply -f -