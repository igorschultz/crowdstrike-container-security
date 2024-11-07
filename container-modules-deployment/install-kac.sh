curl -sSL -o falcon-container-sensor-pull.sh "https://raw.githubusercontent.com/CrowdStrike/falcon-scripts/main/bash/containers/falcon-container-sensor-pull/falcon-container-sensor-pull.sh"
chmod +x falcon-container-sensor-pull.sh

export FALCON_CLIENT_ID=xxxxxxxx
export FALCON_CLIENT_SECRET=xxxxxxxx
K8S_CLUSTER_NAME="$(kubectl config view --minify -o jsonpath='{.contexts[].context.cluster}')"

echo Deploying Falcon Admission Controller
export FALCON_CID=$( ./falcon-container-sensor-pull.sh -t falcon-kac --get-cid )
export FALCON_IMAGE_FULL_PATH=$( ./falcon-container-sensor-pull.sh  -t falcon-kac --get-image-path )
export FALCON_IMAGE_REPO=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 1 )
export FALCON_IMAGE_TAG=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 2 )
export FALCON_IMAGE_PULL_TOKEN=$( ./falcon-container-sensor-pull.sh -t falcon-kac --get-pull-token )

helm repo add crowdstrike https://crowdstrike.github.io/falcon-helm --force-update
helm upgrade --install falcon-kac crowdstrike/falcon-kac -n falcon-kac --create-namespace \
  --set falcon.cid="$FALCON_CID" \
  --set falcon.tags="pov-demo-container" \
  --set image.repository="$FALCON_IMAGE_REPO" \
  --set image.tag="$FALCON_IMAGE_TAG" \
  --set clusterName="$K8S_CLUSTER_NAME" \
  --set image.registryConfigJSON="$FALCON_IMAGE_PULL_TOKEN"