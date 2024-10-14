# [Backstage](https://backstage.io)

This is your newly scaffolded Backstage App, Good Luck!

To start the app, run:

```sh
yarn install
yarn dev
```

[Backstage - UI](http://localhost:3000)
[Backstage - BE](http://localhost:7000)
[Gitlab](http://localhost:8090)
[Jenkins](http://localhost:8080)

```sh
docker-compose up -d
```

```sh
cat <<EOF | kind create cluster --config -
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: backstage-cluster
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
EOF

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

```sh
kubectl create serviceaccount backstage-service-account

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: backstage-cluster-role-binding
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: backstage-service-account
    namespace: default
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: backstage-secret   # Name of the secret
  annotations:
    kubernetes.io/service-account.name: backstage-service-account  # The service account to bind to
type: kubernetes.io/service-account-token
EOF

Token version
kubectl get secret backstage-secret -o jsonpath='{.data.token}' | base64 --decode

CA CRT version
kubectl get secret backstage-secret -o jsonpath='{.data.ca\.crt}'
```
