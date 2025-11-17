curl -sSL -o falcon-container-sensor-pull.sh "https://raw.githubusercontent.com/CrowdStrike/falcon-scripts/main/bash/containers/falcon-container-sensor-pull/falcon-container-sensor-pull.sh"
chmod +x falcon-container-sensor-pull.sh

BACKEND=bpf

export FALCON_CLIENT_ID=xxxxxxxx
export FALCON_CLIENT_SECRET=xxxxxxxx

echo Deploying Falcon Sensor as Daemonset
export FALCON_CID=$( ./falcon-container-sensor-pull.sh  -t falcon-sensor --get-cid )
export FALCON_IMAGE_FULL_PATH=$( ./falcon-container-sensor-pull.sh  -t falcon-sensor --get-image-path )
export FALCON_IMAGE_REPO=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 1 )
export FALCON_IMAGE_TAG=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 2 )
export FALCON_IMAGE_PULL_TOKEN=$( ./falcon-container-sensor-pull.sh  -t falcon-sensor --get-pull-token )

helm repo add crowdstrike https://crowdstrike.github.io/falcon-helm --force-update
helm upgrade --install falcon-sensor crowdstrike/falcon-sensor -n falcon-system --create-namespace \
  --set falcon.cid="$FALCON_CID" \
  --set falcon.tags="pov-demo-container" \
  --set node.image.repository="$FALCON_IMAGE_REPO" \
  --set node.image.tag="$FALCON_IMAGE_TAG" \
  --set node.image.registryConfigJSON="$FALCON_IMAGE_PULL_TOKEN" \
  --set node.backend="$BACKEND"