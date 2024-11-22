# [Backstage](https://backstage.io)

This is your newly scaffolded Backstage App, Good Luck!

To start the app, run:

```sh
yarn install
yarn dev
```

## Useful links

- [Backstage - UI](http://backstage-local:3000)
- [Backstage - BE](http://backstage-local:7007)
- [Gitlab](http://gitlab-local)

## Installation

1. **Add these 2 hostnames to /etc/hosts**

```sh
echo "127.0.0.1 gitlab-local" | sudo tee -a /etc/hosts
echo "127.0.0.1 gitlab-runner" | sudo tee -a /etc/hosts
```

2. **Tilt use docker-compose file as default**

```sh
tilt up
```

The latest command will create and run a container of **gitlab**, **postgres** and **redis**. All of them are mandatory to execute backstage and own templates.

## Run local kubernetes cluster

```sh
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80

# K3D
cat <<EOF | ctlptl apply -f -
apiVersion: ctlptl.dev/v1alpha1
kind: Registry
name: k3d-backstage-registry
port: 5005
---
apiVersion: ctlptl.dev/v1alpha1
kind: Cluster
name: k3d-backstage-cluster
product: k3d
registry: k3d-backstage-registry
k3d:
  v1alpha5Simple:
    kubeAPI:
      host: localhost
      hostPort: 6443
EOF

#KIND
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

cat <<EOF | kubectl apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - command:
    - /agnhost
    - netexec
    - --http-port
    - "8080"
    image: registry.k8s.io/e2e-test-images/agnhost:2.39
    name: foo-app
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
  labels:
    app: foo
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  labels:
    app: foo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: /foo(/|$)(.*)
        backend:
          service:
            name: foo-service
            port:
              number: 8080
      - pathType: Prefix
        path: /bar(/|$)(.*)
        backend:
          service:
            name: bar-service
            port:
              number: 8080
EOF

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

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

tilt up -f Tiltfile-k3d

```
