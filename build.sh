IMAGE=quay.io/cporter/acs-eda
TAG=0.6

podman build -t $IMAGE:$TAG -f ./Dockerfile

podman push $IMAGE:$TAG 
