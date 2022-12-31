#!/bin/sh
echo "Setting up cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --atomic --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.10.1 \
  --set installCRDs=true


tmpl=`cat "cluster_issuer.yaml" | sed "s/{{CERT_EMAIL}}/$1/g"`
echo "$tmpl" | kubectl -n cert-manager apply -f -