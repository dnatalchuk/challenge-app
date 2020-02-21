## Prerequisites:
* `Docker Desktop version: 2.2.0.0`
* `kubernetes v1.15.5`

## Table of contents and structure:
```
.
├── README.md
├── docker_images
│   ├── haproxy
│   │   ├── Dockerfile
│   │   └── haproxy.cfg
│   └── nginx
│       ├── app_1
│       │   ├── Dockerfile
│       │   └── index.html
│       └── app_2
│           ├── Dockerfile
│           └── index.html
├── k8s
│   ├── haproxy
│   │   ├── haproxy_deployment.yaml
│   │   └── haproxy_service.yaml
│   └── nginx
│       ├── nginx_deployment.yaml
│       └── nginx_service.yaml
└── terraform
    ├── README.md
    ├── main.tf
    └── variables.tf
```
## Docker build images instruction:
```
cd ./docker_images/nginx/app_1
docker build -t challenge-app-1:1.0.0 .

cd ../app_2
docker build -t challenge-app-2:1.0.0 .

cd ../../haproxy/
docker build -t haproxy:1.0.0 .
```

## Kubernetes deployment instructions:
```
cd k8s/nginx
kubectl apply -f ./nginx_deployment.yaml
kubectl apply -f ./nnginx_service.yaml

cd ../haproxy/
kubectl apply -f ./haproxy_deployment.yaml
kubectl apply -f ./haproxy_service.yaml
```

## Verification:
```
kubectl get pods # should return similar output as below:

NAME                                  READY   STATUS        RESTARTS   AGE
haproxy-deployment-5cb69c6d5b-wk9jn   1/1     Running       0          16m
nginx-deployment-1-85f4dfb666-npv6r   1/1     Running       0          65m
nginx-deployment-2-5dc975f54-fj2w4    1/1     Running       0          65m
```
* curl output should look as below and each request will be balanced via round-robin, so each request will return another page:
```
➜  ~ curl http://localhost:30000
<html>
<body style="background-color:yellow;">
<h1 style="color:blue; text-align:center;">Hello from app_1!</h1>
</body>
</html>

➜  ~ curl http://localhost:30000
<html>
<body style="background-color:green;">
<h1 style="color:red; text-align:center;">Hello from app_2!</h1>
</body>
</html>
```
