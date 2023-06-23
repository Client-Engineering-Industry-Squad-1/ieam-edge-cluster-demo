#! /bin/bash

source env.sh

IMAGE_BASE=$1
IMAGE_VERSION=$2
OPERATOR_IMAGE_PATH=$IMAGE_BASE:$IMAGE_VERSION

cd config/manager && kustomize edit set image controller="$OPERATOR_IMAGE_PATH" && cd ../..

# Update Version in horizon/hzn.json if you make ANY change
mv horizon/hzn.json /tmp/hzn.json
jq --arg IMAGE_VERSION "$IMAGE_VERSION" '.MetadataVars.SERVICE_VERSION |= $IMAGE_VERSION' /tmp/hzn.json > horizon/hzn.json

make docker-build docker-push IMG=$OPERATOR_IMAGE_PATH

rm operator.tar.gz && rm -rf deploy && mkdir deploy
kustomize build config/default > deploy/kustomize_manifests_operator.yaml
tar -C deploy -czf operator.tar.gz .

# # rm operator.tar.gz && tar -czf operator.tar deploy && gzip operator.tar 
hzn exchange service publish -f horizon/service.definition.json

HZN_POLICY_NAME="samsung/policy-alb-ieam-edge-cluster-app"
hzn exchange deployment addpolicy -f horizon/service.policy.json $HZN_POLICY_NAME
