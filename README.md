# K8s Demo Platform

A production-ready Kubernetes demonstration platform showcasing a full-stack web application deployed using Helm charts. This project demonstrates modern DevOps practices with multi-environment support (dev, staging, production).

## Architecture

```
Internet → Ingress (NGINX) → Frontend (React/Nginx)
                           → Backend API (Go/Gin) → PostgreSQL
                                                  → Redis
```

### Components

| Component | Technology | Port | Description |
|-----------|------------|------|-------------|
| Frontend | React + Nginx | 8080 | Web UI served via Nginx |
| Backend API | Go/Gin | 8080 | REST API service |
| PostgreSQL | PostgreSQL 16.1 | 5432 | Primary database |
| Redis | Redis 7.2.4 | 6379 | Caching layer |

## Project Structure

```
k8s-demo-platform/
├── charts/
│   ├── platform/           # Umbrella chart (main entry point)
│   │   └── templates/
│   │       ├── namespace.yaml
│   │       ├── networkpolicy.yaml
│   │       ├── limitrange.yaml
│   │       └── resourcequota.yaml
│   ├── frontend/           # React frontend chart
│   ├── backend-api/        # Go API chart
│   ├── postgresql/         # Database chart
│   └── redis/              # Cache chart
├── environments/
│   ├── values-dev.yaml     # Development config
│   ├── values-staging.yaml # Staging config
│   └── values-prod.yaml    # Production config
├── Makefile                # Build automation
└── deploy.sh               # Deployment script
```

## Prerequisites

- Kubernetes cluster (1.24+)
- Helm 3.x
- kubectl configured with cluster access
- Ingress controller (nginx-ingress recommended)
- cert-manager (for TLS certificates)

## Quick Start

### Using Make

```bash
# Update Helm dependencies
make deps

# Deploy to development
make deploy-dev

# Deploy to staging
make deploy-staging

# Deploy to production
make deploy-prod
```

### Using deploy.sh

```bash
# Deploy to dev with defaults
./deploy.sh dev

# Deploy to staging with custom namespace
./deploy.sh staging demo-staging

# Deploy to production with custom namespace and release name
./deploy.sh prod demo-prod platform-prod
```

### Manual Deployment

```bash
# Update dependencies
helm dependency update charts/platform

# Deploy
helm upgrade --install demo-platform charts/platform \
  --namespace demo-dev \
  --create-namespace \
  --values environments/values-dev.yaml \
  --wait --timeout 10m
```

## Environment Configuration

| Aspect | Dev | Staging | Production |
|--------|-----|---------|------------|
| Frontend Replicas | 1 | 2 | 3 |
| Backend Replicas | 1 | 2 | 3 |
| Autoscaling | Disabled | 2-8 replicas | 3-15 replicas |
| Image Tags | latest | versioned | versioned |
| Debug Mode | Enabled | Disabled | Disabled |
| DB Storage | 5Gi | 20Gi | 50Gi |
| Backups | Disabled | Disabled | Daily at 2 AM |
| Domain | dev.nikko-demo.io | staging.nikko-demo.io | nikko-demo.io |

## Features

### Security
- **Pod Security**: Non-root execution, read-only filesystem, dropped capabilities
- **Network Policies**: Default deny with explicit allow rules per component
- **Resource Limits**: CPU/memory requests and limits on all pods
- **Secrets Management**: Kubernetes secrets for sensitive data

### High Availability
- **Horizontal Pod Autoscaler (HPA)**: CPU/memory-based scaling
- **Pod Disruption Budgets (PDB)**: Ensures minimum availability during updates
- **Anti-affinity Rules**: Spreads pods across nodes

### Observability
- **Prometheus Integration**: Metrics endpoints and ServiceMonitors
- **Health Probes**: Liveness, readiness, and startup probes
- **Structured Logging**: JSON format in production

### Database Management
- **Persistent Storage**: StatefulSets with PVCs
- **Automated Backups**: CronJob-based S3 backups (production)
- **Metrics Exporters**: PostgreSQL and Redis exporters for Prometheus

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make deps` | Update Helm chart dependencies |
| `make lint` | Lint all Helm charts |
| `make template-dev` | Render templates for dev environment |
| `make template-staging` | Render templates for staging environment |
| `make template-prod` | Render templates for production environment |
| `make deploy-dev` | Deploy to development |
| `make deploy-staging` | Deploy to staging |
| `make deploy-prod` | Deploy to production |
| `make delete-dev` | Delete development deployment |
| `make delete-staging` | Delete staging deployment |
| `make delete-prod` | Delete production deployment |

## Customization

### Override Values

Create a custom values file and pass it during deployment:

```bash
helm upgrade --install demo-platform charts/platform \
  --namespace custom-ns \
  --values environments/values-dev.yaml \
  --values my-overrides.yaml
```

### Enable/Disable Components

```yaml
# In your values file
frontend:
  enabled: true
backend-api:
  enabled: true
redis:
  enabled: true
postgresql:
  enabled: false  # Disable PostgreSQL
```

### Configure Resources

```yaml
backend-api:
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

## Cleanup

```bash
# Delete specific environment
make delete-dev
make delete-staging
make delete-prod

# Or using Helm directly
helm uninstall demo-platform -n demo-dev
```

## Troubleshooting

### View Pod Status
```bash
kubectl get pods -n demo-dev
```

### Check Pod Logs
```bash
kubectl logs -f deployment/demo-platform-backend-api -n demo-dev
```

### Describe Resources
```bash
kubectl describe pod <pod-name> -n demo-dev
```

### Helm Debug
```bash
helm template demo-platform charts/platform \
  --values environments/values-dev.yaml \
  --debug
```

## License

This project is for demonstration purposes.
