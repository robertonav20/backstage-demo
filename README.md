# Backstage Demo

Backstage project is available with docker isn't necessary to run locally and install dependencies

Here the links

- [Backstage - UI](http://backstage-local:3000)
- [Backstage - BE](http://backstage-local:7007)

## Useful links

- [Postgres](postgres-local:5432)
- [Redis](redis-local:6379)
- [Gitlab](http://gitlab-local)
- [ArgoCD](https://argocd-local:7443)

## Installation

1. **Add these 2 hostnames to /etc/hosts**

```sh
echo "127.0.0.1 gitlab-local" | sudo tee -a /etc/hosts
echo "127.0.0.1 gitlab-runner" | sudo tee -a /etc/hosts
echo "127.0.0.1 postgres-local" | sudo tee -a /etc/hosts
echo "127.0.0.1 redis-local" | sudo tee -a /etc/hosts
echo "127.0.0.1 backstage-local" | sudo tee -a /etc/hosts
echo "127.0.0.1 argocd-local" | sudo tee -a /etc/hosts
```

2. **Tilt use docker-compose file as default**

```sh
tilt up
```

The latest command will create and run a container of **gitlab**, **postgres** and **redis**. All of them are mandatory to execute backstage and own templates.

## Kubernetes cluster

To configure kubernetes just run `startup.sh` under folder tools which includes

- Kind cluster called `kind-backstage-demo-cluster`
- NGINX ingress controller
- ArgoCD at `http://argocd-local:7443`
- Backstage credentials to access to kubernetes

The entrypoint for kubernets cluster are `:7080` for http and `:7443` for https

NOTE: additional ingress hostname must be added to `/etc/hosts`

## Run Hello World Template

```sh
docker run --rm -d -p 3001:80/tcp gitlab-local:5050/backstage-demo/hello-world-app/hello-world-app:main-COMMIT
docker run --rm -d -p 8080:8080/tcp gitlab-local:5050/backstage-demo/hello-world-service/hello-world-service:main-COMMIT
```

- [Hello World App](http://hello-world-app-local:7080)
- [Hello World Service](http://hello-world-service-local:7080/api/v1/hello)
