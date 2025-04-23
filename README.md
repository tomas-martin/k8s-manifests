
# Sitio Web Estático en Kubernetes con Minikube

Este proyecto despliega un sitio web estático personalizado utilizando Kubernetes en un entorno local con Minikube y VirtualBox. El contenido del sitio es una página HTML simple servida por Nginx.

## Requisitos

- Git
- Minikube (con driver VirtualBox)
- PowerShell (u otra terminal)
- Kubectl

## Estructura del proyecto

```
K8s-Proyecto/
│
├── static-website/        # Contiene el index.html personalizado
└── k8s-manifests/         # Contiene los manifiestos de Kubernetes
```

## Pasos para ejecutar el entorno

### 1. Crear la estructura de carpetas

```powershell
cd C:mkdir K8s-Proyecto
cd K8s-Proyecto
mkdir static-website
mkdir k8s-manifests
```

### 2. Crear y guardar el archivo `index.html`

Crear el archivo `C:\K8s-Proyecto\static-website\index.html` con el siguiente contenido:

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mi Sitio Web</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background-color: pink;}
        h1 { color: #007acc; }
    </style>
</head>
<body>
    <h1>Bienvenidos al Sitio Web de Tomás Martín</h1>
    <p>Este es un entorno de desarrollo usando Kubernetes en Minikube.</p>
</body>
</html>
```

### 3. Iniciar Minikube

```powershell
minikube start --driver=virtualbox
```

### 4. Crear los manifiestos de Kubernetes

Crear los siguientes archivos dentro de `C:\K8s-Proyecto\k8s-manifests`:

#### `website-pv-pvc.yaml`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: website-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/host_mnt/c/K8s-Proyecto/static-website"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: website-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

#### `website-deployment.yaml`

```yaml
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
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: website-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: website-content
        persistentVolumeClaim:
          claimName: website-pvc
```

#### `website-service.yaml`

```yaml
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
```

### 5. Aplicar los manifiestos

Desde la carpeta `k8s-manifests`, ejecutar:

```powershell
kubectl apply -f website-pv-pvc.yaml
kubectl apply -f website-deployment.yaml
kubectl apply -f website-service.yaml
```

### 6. Acceder al sitio

Puede abrirse directamente en el navegador:

```
http://192.168.59.100:30080
```

O con el comando:

```powershell
minikube service website-service
```

### 7. Solución temporal si la página muestra error 403

Si Nginx muestra "403 Forbidden", es posible que el volumen no se haya montado correctamente. Como solución temporal, se puede crear el archivo dentro del contenedor ejecutando:

```powershell
kubectl exec -it static-website-<nombre-del-pod> -- bash
```

Una vez dentro:

```bash
echo '<h1>Bienvenidos al Sitio Web de Tomás Martín</h1>' > /usr/share/nginx/html/index.html
exit
```

### 8. Verificar el estado del entorno

```powershell
kubectl get all
```

## Observaciones

- Este proyecto no utiliza una imagen Docker personalizada. El contenido del sitio se sirve montando el archivo HTML desde el sistema de archivos local.
- En algunos entornos de Windows, el volumen `hostPath` puede fallar. Se recomienda hacer una imagen personalizada si se quiere mayor estabilidad.
