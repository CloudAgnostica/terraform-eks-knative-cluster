# Derived from:
# 1) https://redhat-developer-demos.github.io/knative-tutorial/knative-tutorial/setup/minikube.html#_install_knative
# 2) https://knative.dev/v0.21-docs/install/any-kubernetes-cluster/#installing-the-serving-component


kubectl apply \
  --filename https://github.com/knative/serving/releases/download/v0.19.0/serving-crds.yaml \
  --filename https://github.com/knative/eventing/releases/download/v0.19.2/eventing-crds.yaml


kubectl api-resources --api-group='serving.knative.dev'

kubectl api-resources --api-group='messaging.knative.dev'

kubectl api-resources --api-group='eventing.knative.dev'

kubectl api-resources --api-group='sources.knative.dev'


kubectl apply \
  --filename \
  https://github.com/knative/serving/releases/download/v0.19.0/serving-core.yaml

kubectl rollout status deploy controller -n knative-serving
kubectl rollout status deploy activator -n knative-serving
kubectl rollout status deploy autoscaler -n knative-serving
kubectl rollout status deploy webhook -n knative-serving

kubectl get pods -n knative-serving

kubectl apply \
  --filename \
    https://github.com/knative/net-kourier/releases/download/v0.19.0/kourier.yaml


kubectl rollout status deploy 3scale-kourier-control -n knative-serving
kubectl rollout status deploy 3scale-kourier-gateway -n kourier-system

kubectl get pods --all-namespaces -l 'app in(3scale-kourier-gateway,3scale-kourier-control)'

kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

kubectl apply \
  --filename https://projectcontour.io/quickstart/contour.yaml

kubectl rollout status ds envoy -n projectcontour
kubectl rollout status deploy contour -n projectcontour

kubectl get pods -n projectcontour

kubectl apply -n kourier-system -f /Users/nishanw/Documents/projects/learn-terraform-provision-eks-cluste-only/ingress-to-kourier.yaml

# https://projectcontour.io/getting-started/
kubectl get -n projectcontour service envoy -o wide


kubectl apply \
  --filename \
  https://github.com/knative/eventing/releases/download/v0.19.2/eventing-core.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/v0.19.2/in-memory-channel.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/v0.19.2/mt-channel-broker.yaml

kubectl rollout status deploy eventing-controller -n knative-eventing
kubectl rollout status deploy eventing-webhook  -n knative-eventing
kubectl rollout status deploy imc-controller  -n knative-eventing
kubectl rollout status deploy imc-dispatcher -n knative-eventing
kubectl rollout status deploy mt-broker-controller -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing


kubectl get pods -n knative-eventing

kubectl create namespace knativetutorial
kubens knativetutorial



