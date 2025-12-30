# K3s Architecture Reference

## What is K3s?

K3s is a lightweight, certified Kubernetes distribution designed for:
- Edge computing
- IoT devices
- CI/CD environments
- ARM architectures
- Homelab/homeserver setups

## K3s vs Full Kubernetes

| Aspect | K3s | Full Kubernetes |
|--------|-----|-----------------|
| Binary size | ~100MB | Several GB |
| Memory usage | 512MB minimum | 2GB+ recommended |
| Components | Single binary | Multiple services |
| Datastore | SQLite/etcd | etcd required |
| Install time | < 1 minute | 15+ minutes |

## K3s Components

### Server (Control Plane)

The K3s server runs:
- API Server
- Scheduler
- Controller Manager
- SQLite/etcd (datastore)
- Flannel (CNI)
- CoreDNS
- Traefik (ingress)
- Local Storage Provider
- Service Load Balancer

### Agent (Worker)

K3s agents run:
- Kubelet
- kube-proxy
- Flannel CNI

## Single Node Setup

For homeserver use, single node is common:
- Server runs all components
- Same node can run workloads
- No separate agent needed

## Multi-Node Setup

For larger homelab setups, multiple nodes can be added:

### Adding Worker Nodes

Worker nodes join the cluster using the K3s agent:

```bash
# On worker node - join existing cluster
curl -sfL https://get.k3s.io | K3S_URL=https://<SERVER_IP>:6443 K3S_TOKEN=<NODE_TOKEN> sh -
```

### Getting Node Token

On the master (server) node:
```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

### Required Ports

| Port | Protocol | Source | Description |
|------|----------|--------|-------------|
| 6443 | TCP | Agents | Kubernetes API |
| 8472 | UDP | All nodes | Flannel VXLAN |
| 10250 | TCP | All nodes | Kubelet metrics |
| 51820 | UDP | All nodes | Flannel WireGuard (if enabled) |

### Verify Multi-Node Cluster

```bash
# On master node
kubectl get nodes
kubectl get pods -A -o wide  # Shows which node runs each pod
```

## K3s-Specific Resources

### HelmChart CRD

K3s uses HelmChart CRDs to deploy Helm charts:

```yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: traefik
  namespace: kube-system
spec:
  chart: traefik
  repo: https://traefik.github.io/charts
  valuesContent: |-
    # Custom values here
```

### HelmChartConfig CRD

Override default Helm chart configurations:

```yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    ports:
      web:
        exposedPort: 80
      websecure:
        exposedPort: 443
```

## Default Components

K3s installs these by default:
- **Traefik** - Ingress controller
- **CoreDNS** - DNS service
- **Flannel** - CNI networking
- **Local-path-provisioner** - Storage
- **Metrics Server** - Resource metrics
- **ServiceLB** - Load balancer for bare metal

## Installation Options

### Disable Components

```bash
# Disable Traefik
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -

# Disable multiple components
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb" sh -
```

### Server Options

```bash
# With external database
--datastore-endpoint="mysql://user:pass@tcp(host:3306)/k3s"

# Cluster init (for HA)
--cluster-init

# Bind to specific interface
--bind-address 192.168.1.100
```

## kubeconfig Location

K3s stores kubeconfig at:
- `/etc/rancher/k3s/k3s.yaml` (root only by default)

For user access:
```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config
```

## Service Management

```bash
# Start K3s
sudo systemctl start k3s

# Stop K3s
sudo systemctl stop k3s

# Check status
sudo systemctl status k3s

# View logs
sudo journalctl -u k3s -f
```

## Data Locations

| Data Type | Location |
|-----------|----------|
| Binary | `/usr/local/bin/k3s` |
| Config | `/etc/rancher/k3s/` |
| Data | `/var/lib/rancher/k3s/` |
| Logs | `journalctl -u k3s` |
| kubeconfig | `/etc/rancher/k3s/k3s.yaml` |

## Uninstall K3s

```bash
# Server uninstall
/usr/local/bin/k3s-uninstall.sh

# Agent uninstall
/usr/local/bin/k3s-agent-uninstall.sh
```

## Common Commands

```bash
# Check nodes
kubectl get nodes

# Check pods in all namespaces
kubectl get pods -A

# Check K3s version
k3s --version

# Check cluster info
kubectl cluster-info

# Check K3s service
sudo systemctl status k3s
```

## Networking

Default networking:
- **Pod CIDR**: 10.42.0.0/16
- **Service CIDR**: 10.43.0.0/16
- **Cluster DNS**: 10.43.0.10

## Storage

Local-path-provisioner:
- StorageClass: `local-path`
- Provisioner: `rancher.io/local-path`
- Path: `/var/lib/rancher/k3s/storage`

## Troubleshooting

### K3s not starting

```bash
# Check logs
sudo journalctl -u k3s --no-pager -n 100

# Check if port 6443 is in use
sudo lsof -i :6443
```

### kubectl not working

```bash
# Ensure kubeconfig is set
export KUBECONFIG=~/.kube/config

# Check permissions
ls -la ~/.kube/config

# Verify connection
kubectl cluster-info
```

### Pods not scheduling

```bash
# Check node status
kubectl describe node

# Check taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```
