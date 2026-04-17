# Kubernetes Architecture

## 1. Current App Analysis

### Application structure
This project is currently organized as a 3-service Docker stack:

- `web`
  - Node-based static host and reverse proxy
  - Serves the Flutter web build packaged in the `web` image (`public/flutter-web`; built during `docker build`)
  - Exposes `/health` for liveness and `/readyz` for dependency-aware readiness
  - Proxies `/api` and `/socket.io` to the backend
  - Container port: `3000`
- `api`
  - Node/Express backend
  - Container port: `4000`
  - Health endpoints available at `/health` and through the web proxy as `/api/health`
- `postgres`
  - PostgreSQL 15
  - Container port: `5432`

### Ports and runtime shape
Current host defaults have been set up around:

- `WEB_HOST_PORT=3017`
- `API_HOST_PORT=4013`
- `DB_HOST_PORT=5436`

Container ports remain:

- `web`: `3000`
- `api`: `4000`
- `postgres`: `5432`

### Environment variables
The app depends on typical runtime configuration like:

- `JWT_SECRET`
- `CORS_ORIGINS`
- `APP_BASE_URL`
- `DATABASE_URL`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`

The frontend is a built Flutter web bundle, so:

- the browser app is static
- the `web` service handles asset serving and API proxying
- the backend and database are where runtime state lives

### Stateless vs stateful

#### Stateless components
These are effectively stateless and suitable for replication:

- `web`
- `api`

They can be replaced or rescheduled if:

- the image is available
- env vars are injected
- the database is reachable

#### Stateful component
This is stateful:

- `postgres`

That is the main HA constraint.

### What could break under failover

#### Web tier
If a `web` pod dies:

- active requests may fail briefly
- new requests can route to a healthy replica

#### API tier
If an `api` pod dies:

- in-flight requests fail
- Kubernetes can direct future traffic to remaining replicas

#### Database tier
If the database or its host node dies:

- writes fail
- most app functionality stops
- stateless app replicas do not save the stack by themselves

### Practical summary
This app is a good candidate for Kubernetes at the app tier:

- `web` and `api` are easy to replicate
- health checks and restarts are straightforward
- failover is meaningful for stateless services

It is not full-stack HA unless the database is also handled properly.

---

## 2. Proposed Kubernetes Architecture

## Target design
A simple k3s layout for this app:

- 2-node k3s cluster
- 1 control-plane node
- 1 worker node
- `web` Deployment with 2 replicas
- `api` Deployment with 2 replicas
- ClusterIP Services
- Ingress via Traefik
- optional Cloudflare in front

### Important 2-node caveat
A 2-node cluster is fine for learning and workload failover, but it is not ideal for true control-plane HA quorum.

The realistic simple topology is:

- Node 1: k3s server/control plane
- Node 2: k3s agent/worker

This gives resume value and workload failover, but not enterprise-grade control plane HA.

### Core Kubernetes components

#### Deployments
Use Deployments for:

- `web`
- `api`

With:

- `replicas: 2`
- readiness probes
- liveness probes
- basic resource requests and limits

#### Services
Use internal ClusterIP Services for:

- `web`
- `api`

Traffic path:

- Ingress -> `web` Service
- `web` pod proxies `/api` to `api` Service

This keeps the current architecture intact.

#### Ingress
Use the default k3s Traefik ingress unless there is a strong reason to replace it.

Recommended route model:

- one hostname
- ingress sends all traffic to `web`
- `web` keeps proxying API traffic internally

This minimizes changes.

### Optional Cloudflare integration

#### Option A: Cloudflare DNS in front of ingress
- Cloudflare DNS points to the public entry for the cluster
- Traefik handles routing
- simplest Kubernetes-native model

#### Option B: Cloudflare Tunnel
- tunnel agent runs on a node or in-cluster
- Cloudflare forwards traffic into the cluster
- no direct public 80/443 exposure required

DNS plus Traefik is easier to reason about.
Tunnel is attractive if you want less direct exposure.

### Traffic flow

1. User hits app hostname
2. Cloudflare receives the request
3. Cloudflare forwards to cluster ingress
4. Ingress routes traffic to `web`
5. `web` serves Flutter assets
6. `web` proxies `/api/*` to `api`
7. `api` reads/writes PostgreSQL

### What happens when a node goes down
If one node fails:

- pods on that node become unavailable
- Deployments recreate replacement pods on the surviving node if capacity exists
- Services update endpoints automatically
- new traffic shifts to healthy pods

If the lost node was only hosting one `web` and one `api` replica:

- service remains available after brief disruption

If the lost node hosted the only PostgreSQL instance:

- the app is still down or severely degraded

---

## 3. Failover Behavior

## How Kubernetes handles node failure
Kubernetes detects node failure through missed heartbeats.

Typical sequence:

1. node stops reporting
2. node becomes `NotReady`
3. pods on that node are considered lost
4. Deployment controllers create replacement pods elsewhere

### Pod rescheduling
For `web` and `api`:

- pods are recreated automatically
- Service discovery updates automatically
- ingress begins routing only to healthy endpoints

### User-visible behavior
Users may see:

- brief failed requests during node-loss detection
- short recovery while replacement pods become ready
- restored service once healthy pods are online

This is not instant failover, but it is a major improvement over a single Docker host.

### Limits of this 2-node design

#### Control plane limit
If the k3s server node dies:

- existing workloads may continue temporarily
- cluster management is degraded
- scheduling new pods becomes difficult

#### Database limit
If PostgreSQL is single-instance:

- database host failure is still a hard outage

#### Storage limit
If anything important lives on node-local storage:

- failover may lose access to it

---

## 4. Data & State Considerations

## Database challenges
The database is the hard part.

### Single Postgres in cluster
If PostgreSQL is a single pod with persistent storage:

You gain:

- app-tier HA
- orchestration
- restart automation

You do not gain:

- true DB failover
- full-stack HA

### Realistic HA options

#### Option A: single Postgres in cluster
- simplest
- acceptable for learning
- not true HA

#### Option B: external managed database
- easiest operational path to real availability
- less “all self-hosted in k3s”

#### Option C: replicated Postgres in cluster
- best HA story
- significantly more complexity
- no longer minimal

For this project, Option A or B is the realistic choice.

## File storage issues
This app appears primarily DB-backed, which helps.

Potential issues only arise if you add:

- uploads
- generated files
- editable content stored on local disk

In Kubernetes, container-local storage should be treated as disposable.

## Is this true HA?

### Yes, for the stateless tier
With `web` and `api` replicated:

- node loss is survivable at the app tier
- pods self-heal
- service routing adapts

### No, not fully, unless the database is solved
Without replicated or external HA Postgres:

- you do not have complete application HA

### Honest conclusion
This setup gives:

- meaningful failover for stateless services
- real Kubernetes experience
- good resume value

It does not deliver full-stack HA unless database availability is addressed separately.
