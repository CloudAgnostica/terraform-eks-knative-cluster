kubectl --namespace kourier-system get service kourier -o yaml  > kourier-system.service.kourier.gitignore.yaml
export SVC_URL=$(yq e '.status.loadBalancer.ingress[0].hostname' kourier-system.service.kourier.gitignore.yaml)
echo "Hostname of ingress loadbalancer: $SVC_URL"

#On a separate window run: watch kubectl get pods -n knativetutorial
curl -H "Host: greeter.knativetutorial.example.com" "$SVC_URL"
curl -H "Host: helloworld-go.knativetutorial.example.com" "$SVC_URL"