#!/bin/sh

set -x

if [ -z "$VAULT_MINIO_READ_ACCESS_TOKEN" ]; then
    echo ERROR: VAULT_MINIO_READ_ACCESS_TOKEN environment variable missing.  Create this secret in OpenShift.
    exit 1
fi

SECRETS=`curl -H "X-Vault-Token: $VAULT_MINIO_READ_ACCESS_TOKEN" -X GET http://vault-labdroid.apps.home.labdroid.newt:8200/v1/secret/minio`

MINIO_ACCESS_KEY=`echo $SECRETS | jq -r .data.MINIO_ACCESS_KEY`
MINIO_SECRET_KEY=`echo $SECRETS | jq -r .data.MINIO_SECRET_KEY`

echo export MINIO_ACCESS_KEY=$MINIO_ACCESS_KEY > minio.env
echo export MINIO_SECRET_KEY=$MINIO_SECRET_KEY >> minio.env

while true; do
    sleep 1000;
done;
