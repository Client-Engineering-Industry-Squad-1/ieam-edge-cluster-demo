#!/bin/bash

DEPLOY_DIR="/home/itzuser/ieam-edge-cluster-demo/deploy"
. ~/env.sh

APP_IMAGE_BASE=$1
IMAGE_VERSION=$2
APP_IMAGE=$APP_IMAGE_BASE:$IMAGE_VERSION
OPERATOR_IMAGE_BASE="docker.io/jennuineness/ieam-edge-operator"
OPERATOR_IMAGE=$OPERATOR_IMAGE_BASE:$IMAGE_VERSION

cd $DEPLOY_DIR/config/manager && kustomize edit set image controller="$OPERATOR_IMAGE" && cd $DEPLOY_DIR
sed -i -e "s|{{APP_IMAGE_BASE}}|$APP_IMAGE_BASE|" config/samples/demo.yaml
sed -i -e "s|{{IMAGE_VERSION}}|$IMAGE_VERSION|" config/samples/demo.yaml


# Update Version in horizon/hzn.json if you make ANY change
mv $DEPLOY_DIR/horizon/hzn.json /tmp/hzn.json
jq --arg IMAGE_VERSION "$IMAGE_VERSION" '.MetadataVars.SERVICE_VERSION |= $IMAGE_VERSION' /tmp/hzn.json > $DEPLOY_DIR/horizon/hzn.json

make -C $DEPLOY_DIR docker-build docker-push IMG=$OPERATOR_IMAGE

rm $DEPLOY_DIR/operator.tar.gz && rm -rf $DEPLOY_DIR/deploy && mkdir $DEPLOY_DIR/deploy
cd $DEPLOY_DIR && kustomize build config/default > deploy/kustomize_manifests_operator.yaml
cd $DEPLOY_DIR && tar -C deploy -czf operator.tar.gz .

# # rm operator.tar.gz && tar -czf operator.tar deploy && gzip operator.tar 
hzn exchange service publish -f $DEPLOY_DIR/horizon/service.definition.json --overwrite
sleep 3

HZN_POLICY_NAME="samsung/policy-alb-ieam-edge-cluster-app"
hzn exchange deployment removepolicy -f $HZN_POLICY_NAME
sleep 5
hzn exchange deployment addpolicy -f $DEPLOY_DIR/horizon/service.policy.json $HZN_POLICY_NAME
