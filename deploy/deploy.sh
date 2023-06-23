#! /bin/bash

export OPERATOR_IMAGE_PATH="$1:$2"
cd config/manager && kustomize edit set image controller="${OPERATOR_IMAGE_PATH}" && cd ../..

# TODO: Update Version in MakeFile if you update OPERATOR image version in yaml

# TODO: Update Version in horizon/hzn.json if you make ANY change

make docker-build docker-push

rm operator.tar.gz && rm -rf deploy
mkdir deploy
kustomize build config/default > deploy/kustomize_manifests_operator.yaml
tar -C deploy -czf operator.tar.gz .

hzn dev service new -V 1.0.0 -s sample-app -c cluster

# TODO: Update horizon/service.definition.json to "operatorYamlArchive": "../operator.tar.gz"
# TODO: Can update horizon/hzn.json "SERVICE_NAME"

# rm operator.tar.gz && tar -czf operator.tar deploy && gzip operator.tar 
hzn exchange service publish -f horizon/service.definition.json

# TODO: Update Version below
export HZN_POLICY_NAME="samsung/policy-alb-sample-app_$2"
hzn exchange deployment addpolicy -f horizon/service.policy.json $HZN_POLICY_NAME
