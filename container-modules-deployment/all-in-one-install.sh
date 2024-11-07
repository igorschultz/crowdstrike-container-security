curl -O https://raw.githubusercontent.com/pbaumbach2/falcon-k8s-cluster-deploy/main/falcon-k8s-cluster-deploy.sh
chmod +x falcon-k8s-cluster-deploy.sh

export FALCON_CLIENT_ID=xxxxxxxx
export FALCON_CLIENT_SECRET=xxxxxxx
export CLUSTER_NAME="$(kubectl config view --minify -o jsonpath='{.contexts[].context.cluster}')"

cat << EOF
=================
Cluster Name: $CLUSTER_NAME
EOF
 
./falcon-k8s-cluster-deploy.sh \
--client-id "$FALCON_CLIENT_ID" \
--client-secret "$FALCON_CLIENT_SECRET" \
--cluster "$CLUSTER_NAME" \
--region "us-2" \
--tags "pov-demo-container" \
--ebpf "true" \
--skip-kpa