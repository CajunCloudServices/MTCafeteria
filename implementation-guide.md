# Implementation Guide

## 1. Cluster Setup Plan

## Cluster shape
Recommended simple k3s layout:

- Node 1: k3s server/control plane
- Node 2: k3s agent/worker

This is the simplest way to get:

- real cluster behavior
- rescheduling between machines
- useful failover demonstration value

## k3s installation plan

### Server node
Install k3s server on the primary node.

This node will:

- host the control plane
- initialize the cluster
- issue the join token
- run Traefik by default unless disabled

### Worker node
Install k3s agent on the second node.

This node will:

- join the existing cluster
- run application workloads
- provide failover capacity

## Networking basics
You need:

- node-to-node reachability
- firewall allowances for k3s communication
- an external path to the ingress layer

Conceptually:

- pods get their own internal IPs
- Services provide stable virtual endpoints
- Ingress provides external HTTP entry

## What to keep simple
Do not add:

- service mesh
- advanced multi-cluster networking
- internal PKI complexity unless needed
- custom ingress unless default Traefik becomes a problem

---

## 2. Deployment Plan

## Resources needed

### Namespace
Recommended:

- one namespace for the app, such as `mtc`

### Secret
Store sensitive values in a Secret:

- `JWT_SECRET`
- DB password
- `DATABASE_URL`

### ConfigMap
Store non-secret config in a ConfigMap:

- `APP_BASE_URL`
- `CORS_ORIGINS`

### Deployment
Create two Deployments:

- `web`
- `api`

Recommended settings:

- `replicas: 2`
- readiness probe
- liveness probe

### Service
Create internal ClusterIP Services:

- `web`
- `api`

### Ingress
Create one Ingress:

- route app hostname to `web`
- keep `/api` handling inside the `web` container proxy

### Database
For minimal implementation:

- run PostgreSQL as a single instance with persistent storage

That is not true HA, but it keeps the project realistic and not overbuilt.

---

## 3. Example YAML

## Namespace
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mtc
```

## ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mtc-config
  namespace: mtc
data:
  APP_BASE_URL: "https://your-app.example.com"
  CORS_ORIGINS: "https://your-app.example.com"
```

## Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mtc-secrets
  namespace: mtc
type: Opaque
stringData:
  JWT_SECRET: "replace-me"
  DATABASE_URL: "postgres://postgres:replace-me@postgres.mtc.svc.cluster.local:5432/mtc_cafeteria"
```

## API Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: mtc
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: your-registry/mtc-api:latest
          ports:
            - containerPort: 4000
          env:
            - name: APP_BASE_URL
              valueFrom:
                configMapKeyRef:
                  name: mtc-config
                  key: APP_BASE_URL
            - name: CORS_ORIGINS
              valueFrom:
                configMapKeyRef:
                  name: mtc-config
                  key: CORS_ORIGINS
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: mtc-secrets
                  key: JWT_SECRET
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: mtc-secrets
                  key: DATABASE_URL
          readinessProbe:
            httpGet:
              path: /health
              port: 4000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 4000
            initialDelaySeconds: 15
            periodSeconds: 20
```

## API Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: mtc
spec:
  selector:
    app: api
  ports:
    - port: 4000
      targetPort: 4000
```

## Web Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: mtc
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: your-registry/mtc-web:latest
          ports:
            - containerPort: 3000
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 15
            periodSeconds: 20
```

## Web Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: mtc
spec:
  selector:
    app: web
  ports:
    - port: 3000
      targetPort: 3000
```

## Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mtc-web
  namespace: mtc
spec:
  ingressClassName: traefik
  rules:
    - host: your-app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 3000
```

## Notes on this YAML
This example intentionally keeps the current architecture intact:

- one hostname
- one public ingress
- frontend remains the entrypoint
- backend remains internal

That makes migration from Docker Compose easier.

---

## 4. Cloudflare Integration Options

## Option A: Cloudflare DNS

### How it works
- Cloudflare DNS record points to your ingress endpoint
- public traffic reaches Traefik
- Traefik routes to `web`

### Failover behavior
If one node dies:

- Kubernetes replaces lost pods on surviving capacity
- Service endpoints update
- Cloudflare continues pointing at the same hostname

### Pros
- simplest model
- strongly aligned with standard Kubernetes ingress
- easiest to explain on a resume

### Cons
- requires public ingress exposure
- depends on firewall/NAT setup

## Option B: Cloudflare Tunnel

### How it works
- Cloudflare forwards traffic into the cluster through a tunnel
- no direct public 80/443 exposure is required

### Failover behavior
Depends on tunnel placement:

- one tunnel on one node creates a weak point
- replicated tunnel placement improves resilience

### Pros
- smaller attack surface
- fits existing Cloudflare familiarity

### Cons
- adds another moving part
- slightly less straightforward than normal ingress

---

## 5. Complexity Breakdown

## k3s install
- Easy

## Joining a second node
- Easy

## Building/publishing images
- Medium

## Kubernetes YAML for app workloads
- Medium

## Services and internal networking
- Easy

## Ingress
- Medium

## Cloudflare DNS
- Easy

## Cloudflare Tunnel
- Medium

## Single PostgreSQL in cluster
- Medium

## Truly HA PostgreSQL
- Hard

## Debugging and operations
- Medium

---

## 6. Estimated Time to Implement

For someone at your level, realistic estimates are:

## Basic cluster and app deployment
- 1 to 2 days

Includes:

- k3s install
- second node join
- simple manifests
- initial app deployment

## Cloudflare integration
- 2 to 4 hours

## Single Postgres with persistence
- 3 to 6 hours

## Making it polished and resume-ready
- 2 to 4 days total

Includes:

- probes
- secrets/config cleanup
- image versioning
- tested failover behavior
- documentation and diagrams

## If you also attempt HA Postgres
- several extra days to a week

---

## Recommended scope

For learning, resume value, and low overengineering:

1. use k3s with 2 nodes
2. run `web` and `api` as 2-replica Deployments
3. use Traefik ingress
4. put Cloudflare in front
5. keep PostgreSQL single-instance at first and document the limitation clearly

That gives you:

- real Kubernetes experience
- meaningful stateless failover
- a clean architecture story
- manageable complexity
