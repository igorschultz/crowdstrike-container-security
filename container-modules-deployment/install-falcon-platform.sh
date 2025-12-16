curl -sSL -o falcon-container-sensor-pull.sh "https://raw.githubusercontent.com/CrowdStrike/falcon-scripts/main/bash/containers/falcon-container-sensor-pull/falcon-container-sensor-pull.sh"
chmod +x falcon-container-sensor-pull.sh

# Global Variables
export FALCON_CLIENT_ID=xxxxxxxx
export FALCON_CLIENT_SECRET=xxxxxxxx
export FALCON_CID=$( ./falcon-container-sensor-pull.sh -t falcon-sensor --get-cid ) 
export FALCON_IMAGE_PULL_TOKEN=$( ./falcon-container-sensor-pull.sh -t falcon-sensor --get-pull-token )

# Falcon Sensor Variables
echo Collecting Falcon Sensor image details..
export FALCON_IMAGE_FULL_PATH=$( ./falcon-container-sensor-pull.sh -t falcon-sensor --get-image-path )
export FALCON_IMAGE_REPO=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 1 )
export FALCON_IMAGE_TAG=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 2 )
echo Done.

# Falcon IAR Variables
echo Collecting IAR image details..
export IAR_IMAGE_FULL_PATH=$( ./falcon-container-sensor-pull.sh -t falcon-imageanalyzer --get-image-path ) 
export IAR_IMAGE_REPO=$( echo $IAR_IMAGE_FULL_PATH | cut -d':' -f 1 )
export IAR_IMAGE_TAG=$( echo $IAR_IMAGE_FULL_PATH | cut -d':' -f 2 )
export CLUSTER_NAME="$(kubectl config view --minify -o jsonpath='{.contexts[].context.cluster}' | cut -d'.' -f 1)"
echo Done.

# Falcon KAC Variables
echo Collecting KAC image details..
export KAC_IMAGE_FULL_PATH=$( ./falcon-container-sensor-pull.sh -t falcon-kac --get-image-path )
export KAC_IMAGE_REPO=$( echo $KAC_IMAGE_FULL_PATH | cut -d':' -f 1 )
export KAC_IMAGE_TAG=$( echo $KAC_IMAGE_FULL_PATH | cut -d':' -f 2 )
echo Done.

helm repo add crowdstrike https://crowdstrike.github.io/falcon-helm --force-update
helm install falcon-platform crowdstrike/falcon-platform --version 1.0.0\
  --namespace falcon-platform \
  --create-namespace \
  --set createComponentNamespaces=true \
  --set global.falcon.cid=$FALCON_CID \
  --set global.containerRegistry.configJSON=$FALCON_IMAGE_PULL_TOKEN \
  --set falcon-sensor.node.image.repository=$FALCON_IMAGE_REPO \
  --set falcon-sensor.node.image.tag=$FALCON_IMAGE_TAG \
  --set falcon-sensor.falcon.tags="pov-demo-container" \
  --set falcon-kac.image.repository=$KAC_IMAGE_REPO \
  --set falcon-kac.image.tag=$KAC_IMAGE_TAG \
  --set falcon-kac.falcon.tags="pov-demo-container" \
  --set falcon-image-analyzer.deployment.enabled=true \
  --set falcon-image-analyzer.image.repository=$IAR_IMAGE_REPO \
  --set falcon-image-analyzer.image.tag=$IAR_IMAGE_TAG \
  --set falcon-image-analyzer.crowdstrikeConfig.clusterName=$CLUSTER_NAME \
  --set falcon-image-analyzer.crowdstrikeConfig.clientID=$FALCON_CLIENT_ID \
  --set falcon-image-analyzer.crowdstrikeConfig.clientSecret=$FALCON_CLIENT_SECRET