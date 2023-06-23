#!/bin/bash

DEPLOY_DIR="/home/itzuser/ieam-edge-cluster-demo/deploy"
. $DEPLOY_DIR/env.sh

APP_IMAGE_BASE=$1
IMAGE_VERSION=$2
APP_IMAGE=$APP_IMAGE_BASE:$IMAGE_VERSION
OPERATOR_IMAGE_BASE="docker.io/jennuineness/ieam-edge-operator"
OPERATOR_IMAGE=$OPERATOR_IMAGE_BASE:$IMAGE_VERSION

cd $DEPLOY_DIR/config/manager && kustomize edit set image controller="$OPERATOR_IMAGE" && cd $DEPLOY_DIR
cd $DEPLOY_DIR/config/samples && kustomize edit set image nginx="$APP_IMAGE" && cd $DEPLOY_DIR

# Update Version in horizon/hzn.json if you make ANY change
mv $DEPLOY_DIR/horizon/hzn.json /tmp/hzn.json
jq --arg IMAGE_VERSION "$IMAGE_VERSION" '.MetadataVars.SERVICE_VERSION |= $IMAGE_VERSION' /tmp/hzn.json > $DEPLOY_DIR/horizon/hzn.json

make -C $DEPLOY_DIR docker-build docker-push IMG=$OPERATOR_IMAGE

rm $DEPLOY_DIR/operator.tar.gz && rm -rf $DEPLOY_DIR/deploy && mkdir $DEPLOY_DIR/deploy
kustomize build $DEPLOY_DIR/config/default > $DEPLOY_DIR/deploy/kustomize_manifests_operator.yaml
cd $DEPLOY_DIR && tar -C deploy -czf operator.tar.gz .

# # rm operator.tar.gz && tar -czf operator.tar deploy && gzip operator.tar 
hzn exchange service publish -f $DEPLOY_DIR/horizon/service.definition.json --overwrite
sleep 3

HZN_POLICY_NAME="samsung/policy-alb-ieam-edge-cluster-app"
hzn exchange deployment addpolicy -f $DEPLOY_DIR/horizon/service.policy.json $HZN_POLICY_NAME
