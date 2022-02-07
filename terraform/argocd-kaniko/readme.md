kubectl create secret \
docker-registry dockerhub-registry \
--docker-server=$REGISTRY_SERVER \
--docker-username=$REGISTRY_USER \
--docker-password=$REGISTRY_PASS \
--docker-email=$REGISTRY_EMAIL