# CrowdStrike Falcon Platform Helm Chart

The Falcon Platform Helm Chart deploys the complete CrowdStrike Falcon Kubernetes runtime security
platform. This umbrella chart manages all individual Falcon components as dependencies, providing
unified deployment and configuration.

## Falcon-Platform Overview

The Falcon Platform Helm chart allows you to deploy and manage the entire CrowdStrike Falcon Kubernetes runtime security stack with a single Helm installation. It coordinates the deployment of multiple security components while providing centralized configuration management and deployment orchestration.

### Components

The platform manages three core security components as dependencies, with the Falcon Sensor
supporting one of two deployment modes.

| Component                                                                 | Purpose                                                 | Default Status |
|---------------------------------------------------------------------------|---------------------------------------------------------|----------------|
| [**Falcon Node Sensor**](/helm-charts/falcon-sensor/README.md)            | Daemonset for runtime node protection and monitoring    | Enabled        |
| [**Falcon Container Sensor**](/helm-charts/falcon-sensor/README.md)       | Sidecar for runtime container protection and monitoring | Disabled       |
| [**Falcon KAC**](/helm-charts/falcon-kac/README.md)                       | Kubernetes admission controller for policy enforcement  | Enabled        |
| [**Falcon Image Analyzer**](/helm-charts/falcon-image-analyzer/README.md) | Container image vulnerability scanning and assessment   | Enabled        |

### Purpose

To facilitate quick deployment of recommended CWP resources for testing.

For other deployment methods including hosting sensor in private registry, Terraform, etc., see CrowdStrike documentation and CrowdStrike GitHub.

## Prerequisites

### Minimum Requirements

- Helm 3.x
- Falcon Customer ID (CID)
- Appropriate cluster permissions (cluster-admin) for installation
- Falcon registry access to pull Falcon component container images
- Falcon OAuth client credentials
  - Required Permissions:
    - Falcon Container CLI: Write
    - Falcon Container Image: Read/Write
    - Falcon Images Download: Read

### 1. Set your environment variables:

```bash
export FALCON_CID=<your-falcon-cid>
export ENCODED_DOCKER_CONFIG=<your-base64-encoded-docker-config>
export SENSOR_REGISTRY=<your-sensor-registry>
export SENSOR_IMAGE_TAG=<your-falcon-sensor-image-tag>
export KAC_REGISTRY=<your-kac-registry>
export KAC_IMAGE_TAG=<your-falcon-kac-image-tag>
export IAR_REGISTRY=<your-iar-registry>
export IAR_IMAGE_TAG=<your-falcon-iar-image-tag>
export CLUSTER_NAME=<your-cluster-name>
export FALCON_CLIENT_ID=<your-falcon-client-id>
export FALCON_CLIENT_SECRET=<your-falcon-client-secret>
```

### 2. Add the Helm Repository

```bash
helm repo add crowdstrike https://crowdstrike.github.io/falcon-helm
helm repo update
```

### 3. Deploy the Helm Chart

Deploy all 3 components using `--set` arguments to pass configuration values directly. The
`createComponentNamespaces=true` setting automatically creates the required namespaces for each
component.

```bash
helm install falcon-platform crowdstrike/falcon-platform --version 1.0.0 \
  --namespace falcon-platform \
  --create-namespace \
  --set createComponentNamespaces=true \
  --set global.falcon.cid=$FALCON_CID \
  --set global.containerRegistry.configJSON=$ENCODED_DOCKER_CONFIG \
  --set falcon-sensor.node.image.repository=$SENSOR_REGISTRY \
  --set falcon-sensor.node.image.tag=$SENSOR_IMAGE_TAG \
  --set falcon-kac.image.repository=$KAC_REGISTRY \
  --set falcon-kac.image.tag=$KAC_IMAGE_TAG \
  --set falcon-image-analyzer.deployment.enabled=true \
  --set falcon-image-analyzer.image.repository=$IAR_REGISTRY \
  --set falcon-image-analyzer.image.tag=$IAR_IMAGE_TAG \
  --set falcon-image-analyzer.crowdstrikeConfig.clusterName=$CLUSTER_NAME \
  --set falcon-image-analyzer.crowdstrikeConfig.clientID=$FALCON_CLIENT_ID \
  --set falcon-image-analyzer.crowdstrikeConfig.clientSecret=$FALCON_CLIENT_SECRET
```

## Verify Falcon Platform Deployment

### Check Installation Status

```bash
# Check overall falcon-platform release status
helm list -n falcon-platform

# Expected Output:
NAME           	NAMESPACE      	REVISION	UPDATED                             	STATUS  	CHART                	APP VERSION
falcon-platform	falcon-platform	1       	2025-10-06 16:54:28.315583 -0400 EDT	deployed	falcon-platform-1.0.0

# Check all pods with the falcon-platform label
kubectl get pods -l app.kubernetes.io/instance=falcon-platform -A

# Expected Output:
NAMESPACE               NAME                                          READY   STATUS    RESTARTS   AGE
falcon-image-analyzer   falcon-platform-falcon-image-analyzer-xxxxx   1/1     Running   0          2m
falcon-kac              falcon-kac-xxxxxxxxx-xxxxx                    3/3     Running   0          2m
falcon-system           falcon-platform-falcon-sensor-xxxxx           1/1     Running   0          2m
```

### Uninstall Helm Chart

To uninstall, run the following command:

```bash
helm uninstall falcon-platform -n falcon-platform
```
