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
    extraMounts:
      - containerPath: /etc/ssl/certs/ZSCALER_2025.pem
        hostPath: /etc/ssl/certs/ZSCALER_2025.pem
      - containerPath: /etc/ssl/certs/ZSCALER_DOCKER_2025.pem
        hostPath: /etc/ssl/certs/ZSCALER_DOCKER_2025.pem
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

sleep 40

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
  - host: argocd.local
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

ARGOCD_USER=argo-admin-user

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  admin.enabled: "true"
  accounts.$ARGOCD_USER.enabled: "true"
  accounts.$ARGOCD_USER: apiKey, login
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    g, $ARGOCD_USER, role:admin
EOF

kubectl rollout restart deployment argocd-server -n argocd

sleep 40

ARGOCD_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo)

echo $ARGOCD_USER
echo $ARGOCD_ADMIN_PASSWORD

argocd login argocd.local:7443 --insecure --grpc-web --username admin --password $ARGOCD_ADMIN_PASSWORD
ARGOCD_TOKEN=$(argocd account generate-token --insecure --grpc-web --account $ARGOCD_USER)
echo $ARGOCD_TOKEN

argocd account update-password --account $ARGOCD_USER --current-password $ARGOCD_ADMIN_PASSWORD --new-password "$ARGOCD_USER-password"
ARGOCD_USER_PASSWORD=$ARGOCD_USER-password
echo $ARGOCD_USER_PASSWORD

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

#Client Key
echo "Backstage Token"
kubectl -n default get secret backstage-secret -o jsonpath='{.data.token}' | base64 --decode

#Client Certificate
echo "\n\nBackstage CRT"
kubectl -n default get secret backstage-secret -o jsonpath='{.data.ca\.crt}'