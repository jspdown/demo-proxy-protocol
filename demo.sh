#! /bin/sh

TRAEFIK_PID_FILE=/tmp/pid.traefik

case "$1" in
  prepare)
    # Avoid spending too much time pulling images during the demo.
    echo "Fetching docker images locally..."
    docker pull traefik:v2.4.0
    docker pull rancher/klipper-lb:v0.1.2
    docker pull jspdown/whoamitcp:demo-proxy-protocol
  ;;

  proxy1)
    echo "Starting Proxy 1..."
    traefik --configFile=./proxy1.static.yaml
  ;;

  proxy2)
    echo "Starting K8s cluster..."
    k3d cluster delete demo-proxy-protocol
    k3d cluster create demo-proxy-protocol \
      -p 9001:9000@loadbalancer \
      -p 8081:8080@loadbalancer \
      --k3s-server-arg '--no-deploy=traefik' \
      -i rancher/k3s:v1.18.6-k3s1
    
    k3d image import -c demo-proxy-protocol \
      traefik:v2.4.0 \
      jspdown/whoamitcp:demo-proxy-protocol \
      rancher/klipper-lb:v0.1.2
    
    echo "\nStarting Proxy 2..."
    kubectl apply -f crd.yaml
    kubectl apply -f proxy2.yaml
    
    echo "\nStarting the backend application..."
    kubectl apply -f backend.yaml

    kubectl wait pod/traefik --for=condition=Ready --timeout=-1s
    kubectl logs -f pod/traefik
  ;;

  stop)
    echo "Stopping K8s cluster..."
    k3d cluster delete demo-proxy-protocol
  ;;

esac
