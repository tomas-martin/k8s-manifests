#!/bin/bash

set -e  # Detener en caso de error

echo "🚀 Iniciando Minikube con driver Docker..."
minikube start --driver=docker

echo "🔧 Configurando entorno Docker de Minikube..."
eval $(minikube -p minikube docker-env)

echo "📁 Preparando estructura del proyecto..."
mkdir -p ~/K8s-Proyecto/static-website
cd ~/K8s-Proyecto/static-website

echo "📝 Creando archivo index.html..."
cat <<EOF > index.html
<!DOCTYPE html>
<html lang=\"es\">
<head>
  <meta charset=\"UTF-8\">
  <title>Mi Sitio Web - Martin</title>
  <style>
    body { background-color: #f0f2f5; font-family: Arial, sans-serif; text-align: center; padding: 80px; }
    h1 { color: #004aad; }
    p { font-size: 1.2em; }
  </style>
</head>
<body>
  <h1>Bienvenidos al Sitio Web de Tomas Martin</h1>
  <p>Desplegado con Kubernetes y Docker en Minikube.</p>
</body>
</html>
EOF

echo "📦 Creando Dockerfile..."
cat <<EOF > Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EOF

echo "🐳 Construyendo imagen personalizada..."
docker build -t static-website:1.0 .

echo "📁 Creando manifiesto Kubernetes..."
mkdir -p ../k8s-manifests
cd ../k8s-manifests

cat <<EOF > website-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-website
spec:
  replicas: 1
  selector:
    matchLabels:
      app: static-website
  template:
    metadata:
      labels:
        app: static-website
    spec:
      containers:
        - name: static-website
          image: static-website:1.0
          ports:
            - containerPort: 80
EOF

cat <<EOF > website-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: website-service
spec:
  type: NodePort
  selector:
    app: static-website
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
EOF

echo "🚀 Desplegando en Kubernetes..."
kubectl apply -f website-deployment.yaml
kubectl apply -f website-service.yaml

echo "🌐 Accedé a tu sitio web en: http://$(minikube ip):30080"
kubectl get pods
kubectl get svc

