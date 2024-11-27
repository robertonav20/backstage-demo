#KIND
cat <<EOF | kind create cluster --config -
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: backstage-demo-cluster
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
        hostPort: 7080
        protocol: TCP
      - containerPort: 443
        hostPort: 7443
        protocol: TCP
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."172.17.0.1:5050"]
    endpoint = ["http://172.17.0.1:5050"]
  [plugins."io.containerd.grpc.v1.cri".registry.configs."172.17.0.1:5050".tls]
    insecure_skip_verify = true
EOF

kubectl cluster-info

#NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

sleep 5

#ARGOCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 20

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    alb.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd-local
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: argocd-server
            port:
              number: 443
EOF

kubectl config set-context --current --namespace=default

kubectl create secret docker-registry gitlab-local-container-registry-auth \
  --docker-server=http://172.17.0.1:5050 \
  --docker-username=root \
  --docker-password=glpat-zQ-yQ8VyW37oRSbEnWAx \
  --docker-email=gitlab_admin_2ec6a0@example.com

#BACKSTAGE
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

#Token version
echo "Backstage Token"
kubectl get secret backstage-secret -o jsonpath='{.data.token}' | base64 --decode

#CA CRT version
echo "Backstage CRT"
kubectl get secret backstage-secret -o jsonpath='{.data.ca\.crt}'