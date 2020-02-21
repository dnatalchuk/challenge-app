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