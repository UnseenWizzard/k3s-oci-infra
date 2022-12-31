#!/bin/sh
cd cert-manager
read -p 'email for letsEncrypt: ' mail
./setup.sh $mail
cd ../longhorn
read -p 'public url for ingress: ' host
./setup.sh $host