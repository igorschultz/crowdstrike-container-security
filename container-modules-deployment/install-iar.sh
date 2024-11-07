curl -sSL -o falcon-container-sensor-pull.sh "https://raw.githubusercontent.com/CrowdStrike/falcon-scripts/main/bash/containers/falcon-container-sensor-pull/falcon-container-sensor-pull.sh"
chmod +x falcon-container-sensor-pull.sh

FALCON_CLOUD=us-1
AZURE=false
K8S_CLUSTER_NAME="$(kubectl config view --minify -o jsonpath='{.contexts[].context.cluster}')"

export FALCON_CLIENT_ID=xxxxxxxx
export FALCON_CLIENT_SECRET=xxxxxxxx

echo Deploying Image Assessment at Runtime
export FALCON_CID=$( ./falcon-container-sensor-pull.sh -t falcon-imageanalyzer --get-cid )
export FALCON_IMAGE_FULL_PATH=$( ./falcon-container-sensor-pull.sh -t falcon-imageanalyzer --get-image-path )
export FALCON_IMAGE_REPO=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 1 )
export FALCON_IMAGE_TAG=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 2 )
export FALCON_IMAGE_PULL_TOKEN=$( ./falcon-container-sensor-pull.sh  -t falcon-imageanalyzer --get-pull-token )

helm repo add crowdstrike https://crowdstrike.github.io/falcon-helm --force-update
helm upgrade --install iar crowdstrike/falcon-image-analyzer -n falcon-image-analyzer --create-namespace \
  --set deployment.enabled=true \
  --set crowdstrikeConfig.cid="$FALCON_CID" \
  --set crowdstrikeConfig.clusterName="$K8S_CLUSTER_NAME" \
  --set crowdstrikeConfig.clientID=$FALCON_CLIENT_ID \
  --set crowdstrikeConfig.clientSecret=$FALCON_CLIENT_SECRET \
  --set crowdstrikeConfig.agentRegion=$FALCON_CLOUD \
  --set image.registryConfigJSON=$FALCON_IMAGE_PULL_TOKEN \
  --set image.repository="$FALCON_IMAGE_REPO" \
  --set image.tag="$FALCON_IMAGE_TAG" \
  --set azure.enabled=$AZURE