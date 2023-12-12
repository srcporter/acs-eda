IMAGE=quay.io/cporter/acs-eda
TAG=0.9

podman build -t $IMAGE:$TAG -f ./Dockerfile

podman push $IMAGE:$TAG 
