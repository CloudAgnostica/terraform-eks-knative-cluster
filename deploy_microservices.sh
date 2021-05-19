#From https://redhat-developer-demos.github.io/knative-tutorial/knative-tutorial/serving/knative-client.html
kn service create greeter \
  --image quay.io/rhdevelopers/knative-tutorial-greeter:quarkus

# variations of listing Knative serving service
kn service list
kubectl get ksvc

#Describing the service's route
kn route describe greeter

