# ieam-edge-cluster-demo
- [ieam-edge-cluster-demo](#ieam-edge-cluster-demo)
  - [Pre-Requisites](#pre-requisites)
  - [Setting up Linux VM](#setting-up-linux-vm)
  - [Installing OpenShift Pipelines](#installing-openshift-pipelines)
  - [Setting up Namespace](#setting-up-namespace)
  - [Creating the Pipeline](#creating-the-pipeline)

## Pre-Requisites
1. IBM Edge Application Manager Hub (`v4.5`) w/ IEAM Agent installed on a Cluster
2. OpenShift Cluster v4.10+
3. Linux VM with ssh access and the following tools installed:
   1. [Docker](https://docs.docker.com/engine/install/)
   2. [Horizon CLI](https://www.ibm.com/docs/en/eam/4.5?topic=cli-installing-hzn)
   3. [jq](https://jqlang.github.io/jq/download/)
   4. [git](https://git-scm.com/download/)
   5. [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
4. Fork the [IEAM Edge Cluster Demo](https://github.com/Client-Engineering-Industry-Squad-1/ieam-edge-cluster-demo) repository
5. Public container image repository
   * The demo uses DockerHub

## Setting up Linux VM
* Clone your forked Git repository of IEAM Edge Cluster Demo in the Linux VM using SSH
  * `git clone <YOUR_FORKED_IEAM_EDGE_CLUSTER_DEMO_REPO`
* Create a `env.sh` file in user home (`~`) directory based on the `example-env.sh` file in this project
  * Make sure your `agent-install.crt` file is saved in the VM and set the variable `HZN_MGMT_HUB_CERT_PATH` to the file path of the crt
* Ensure user can run commands without sudo
  * Run `docker ps`
    * If you get a `Got permission denied while trying to connect to the Docker daemon socket...` error, then follow instructions in this [document](https://docs.docker.com/engine/install/linux-postinstall/)
* Log into the image registry where you will be pushing your operator and app images
  * `docker login <YOUR_IMAGE_REGISTRY> -u <USERNAME>`

## Installing OpenShift Pipelines
* Install OpenShift Pipelines using the Operator by following the [official documentation](https://docs.openshift.com/container-platform/4.11/cicd/pipelines/installing-pipelines.html#op-installing-pipelines-operator-in-web-console_installing-pipelines)

## Setting up Namespace
* Create a namespace called `ieam-demo`
* Create an image pull Secret called `docker-registry` for the container registry where the application and operator image will be pulled

## Creating the Pipeline
1. Log into the OpenShift cluster where OpenShift Pipelines is installed
2. Create a namespace called `openshift-pipelines`. We will be using this namespace for all other steps.
3. Create an image pull Secret called `docker-registry` where the application and operator image will be uploaded
4. Add the secret to the `pipeline` Service Account

