# VetCare Laravel Application - Kubernetes Documentation

## 🏗️ Architecture Overview

This Kubernetes setup deploys a **Laravel VetCare application** with the following components:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│ Port Forward/   │───▶│  Laravel App     │───▶│   PostgreSQL    │
│ NodePort Access │    │   (Port 8000)    │    │   (Port 5432)   │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Core Components

| Component | Description | Replicas | Image |
|-----------|-------------|----------|-------|
| **Laravel App** | Main web application | 3 | `aelmas0/vetcare-laravel-cdv:latest` |
| **Frontend App** | React/Vue frontend | 2 | `aelmas0/vetcare-frontend:latest` |
| **PostgreSQL** | Database server | 1 | `postgres:15` |

---

## 📁 File Structure

```
k8s/
├── app-deployment.yaml     # Laravel application deployment
├── app.service.yaml        # Laravel service (ClusterIP)
├── fe-deployment.yaml      # Frontend application deployment  
├── fe-service.yaml         # Frontend service (ClusterIP)
├── configmap.yaml          # Application configuration
├── secret.yaml            # Database credentials
├── db-deployment.yaml     # PostgreSQL deployment
├── db-service.yaml        # PostgreSQL service
├── db-pvc.yaml           # Database persistent storage
├── migrate-job.yaml      # Database migration job
└── seed-job.yaml         # Database seeding job
```

---

## 🚀 Quick Start Commands

### Deploy Everything
```bash
# Apply all resources at once
kubectl apply -f .

# Or apply in order (recommended for first deployment)
kubectl apply -f secret.yaml
kubectl apply -f configmap.yaml
kubectl apply -f db-pvc.yaml
kubectl apply -f db-deployment.yaml
kubectl apply -f db-service.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f app.service.yaml
kubectl apply -f fe-deployment.yaml
kubectl apply -f fe-service.yaml
```

### Run Database Setup
```bash
# Run migrations (required for first setup)
kubectl apply -f migrate-job.yaml

# Run seeds (optional - populate with sample data)
kubectl apply -f seed-job.yaml
```

---

## 📊 Monitoring & Status Commands

### Check Overall Status
```bash
# View all resources
kubectl get all

# Check pods status
kubectl get pods

# Check services
kubectl get svc
```

### Detailed Information
```bash
# Describe a pod (replace POD_NAME)
kubectl describe pod <POD_NAME>

# Check pod logs
kubectl logs <POD_NAME>

# Follow logs in real-time
kubectl logs -f <POD_NAME>

# Check events (troubleshooting)
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Application-Specific Status
```bash
# Check Laravel app status
kubectl get pods -l app=laravel-app

# Check database status  
kubectl get pods -l app=postgres

# Check HPA (Horizontal Pod Autoscaler)
kubectl get hpa

# Check resource usage
kubectl top pods
```

---

## 🔧 Management Commands

### Scaling
```bash
# Manual scaling
kubectl scale deployment laravel-app --replicas=3

# Check current HPA status
kubectl get hpa laravel-app

# Edit HPA settings
kubectl edit hpa laravel-app
```

### Updates & Rollouts
```bash
# Update application image
kubectl set image deployment/laravel-app laravel=aelmas0/vetcare-laravel-cdv:new-tag

# Check rollout status
kubectl rollout status deployment/laravel-app

# Rollback to previous version
kubectl rollout undo deployment/laravel-app

# View rollout history
kubectl rollout history deployment/laravel-app
```

### Configuration Management
```bash
# Edit ConfigMap
kubectl edit configmap laravel-config

# Edit Secret
kubectl edit secret laravel-secret

# Restart deployment after config changes
kubectl rollout restart deployment/laravel-app
```

---

## 🗄️ Database Management

### Access Database
```bash
# Get PostgreSQL pod name
kubectl get pods -l app=postgres

# Connect to database (replace POD_NAME)
kubectl exec -it <POSTGRES_POD_NAME> -- psql -U laravel -d vetcare

# Run database commands
kubectl exec -it <POSTGRES_POD_NAME> -- psql -U laravel -d vetcare -c "SELECT * FROM users;"
```

### Database Operations
```bash
# Run fresh migrations
kubectl delete job laravel-migrate
kubectl apply -f migrate-job.yaml

# Check migration job status
kubectl get jobs
kubectl logs job/laravel-migrate

# Backup database (example)
kubectl exec <POSTGRES_POD_NAME> -- pg_dump -U laravel vetcare > backup.sql
```

---

## 🌐 Accessing the Application

### Method 1: Port Forwarding (Recommended for Development)
```bash
# Forward Laravel backend service
kubectl port-forward svc/laravel-service 8080:80
# Access backend API: http://localhost:8080/api

# Forward Frontend service (in another terminal)
kubectl port-forward svc/fe-service 3000:80
# Access frontend: http://localhost:3000
```

### Method 2: NodePort Access
```bash
# Get Minikube IP
minikube ip

# Convert services to NodePort type for external access
kubectl patch svc laravel-service -p '{"spec":{"type":"NodePort"}}'
kubectl patch svc fe-service -p '{"spec":{"type":"NodePort"}}'

# Get assigned NodePorts
kubectl get svc

# Access via: http://<MINIKUBE_IP>:<NODEPORT>
```

### Method 3: LoadBalancer (Cloud Environments)
```bash
# Convert to LoadBalancer type if supported
kubectl patch svc laravel-service -p '{"spec":{"type":"LoadBalancer"}}'
kubectl patch svc fe-service -p '{"spec":{"type":"LoadBalancer"}}'

# Get external IP
kubectl get svc
```

---

## 🔍 Troubleshooting Commands

### Pod Issues
```bash
# Check pod status and events
kubectl describe pod <POD_NAME>

# Check logs for errors
kubectl logs <POD_NAME> --previous

# Get shell access to pod
kubectl exec -it <POD_NAME> -- /bin/bash
```

### Network Issues
```bash
# Test service connectivity
kubectl run debug --image=busybox -it --rm -- nslookup laravel-service

# Check endpoints
kubectl get endpoints

# Test service ports
kubectl port-forward svc/laravel-service 8080:80
curl http://localhost:8080/api/health
```

### Resource Issues
```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check limits and requests
kubectl describe pod <POD_NAME> | grep -A 5 Resources

# Check HPA metrics
kubectl describe hpa laravel-app
```

### Storage Issues
```bash
# Check persistent volumes
kubectl get pv
kubectl get pvc

# Check volume mounts
kubectl describe pod <POSTGRES_POD_NAME> | grep -A 10 Mounts
```

---

## ⚙️ Configuration Details

### Environment Variables
| Variable | Source | Description |
|----------|--------|-------------|
| `DB_CONNECTION` | ConfigMap | Database type (pgsql) |
| `DB_HOST` | ConfigMap | Database hostname (postgres) |
| `DB_PORT` | ConfigMap | Database port (5432) |
| `DB_DATABASE` | ConfigMap | Database name (vetcare) |
| `DB_USERNAME` | Secret | Database username (laravel) |
| `DB_PASSWORD` | Secret | Database password (laravel) |

### Resource Limits
```yaml
# Laravel App Resources
requests:
  cpu: 100m        # 0.1 CPU cores
limits:
  cpu: 500m        # 0.5 CPU cores

# HPA Settings
minReplicas: 1
maxReplicas: 5
targetCPUUtilization: 20%
```

### Persistent Storage
- **PostgreSQL Data**: 1Gi persistent volume
- **Storage Class**: Default (minikube)
- **Access Mode**: ReadWriteOnce

---

## 🔄 Common Workflows

### Complete Reset
```bash
# Delete everything
kubectl delete -f .

# Clean up PVC (WARNING: destroys data)
kubectl delete pvc postgres-pvc

# Redeploy
kubectl apply -f .
kubectl apply -f migrate-job.yaml
```

### Application Update
```bash
# Update image
kubectl set image deployment/laravel-app laravel=aelmas0/vetcare-laravel-cdv:v2.0

# Run migrations if needed
kubectl delete job laravel-migrate
kubectl apply -f migrate-job.yaml

# Check rollout
kubectl rollout status deployment/laravel-app
```

### Debug Application
```bash
# Check app logs
kubectl logs -l app=laravel-app -f

# Get shell in Laravel container
kubectl exec -it deployment/laravel-app -- /bin/bash

# Run Laravel commands
kubectl exec -it deployment/laravel-app -- php artisan config:cache
kubectl exec -it deployment/laravel-app -- php artisan route:list
```

---

## 📋 Health Checks

### Application Health
```bash
# Check if app is responding
kubectl port-forward svc/laravel-service 8080:80
curl http://localhost:8080

# Check database connectivity
kubectl exec deployment/laravel-app -- php artisan tinker --execute="DB::connection()->getPdo();"
```

### System Health
```bash
# Check cluster status
kubectl cluster-info

# Check node resources
kubectl describe nodes

# Check all services
kubectl get svc --all-namespaces
```

---

## 🚨 Emergency Procedures

### Application Down
```bash
# Quick restart
kubectl rollout restart deployment/laravel-app

# Scale up immediately
kubectl scale deployment laravel-app --replicas=3

# Check what's wrong
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Database Issues
```bash
# Restart PostgreSQL
kubectl rollout restart deployment/postgres

# Check database logs
kubectl logs -l app=postgres -f

# Emergency DB access
kubectl exec -it deployment/postgres -- psql -U postgres
```

### Service Issues
```bash
# Check service configuration
kubectl describe svc laravel-service
kubectl describe svc fe-service

# Test external access
kubectl port-forward svc/laravel-service 8080:80
kubectl port-forward svc/fe-service 3000:80

# Check service logs
kubectl logs -l app=laravel-app
kubectl logs -l app=fe-app
```
