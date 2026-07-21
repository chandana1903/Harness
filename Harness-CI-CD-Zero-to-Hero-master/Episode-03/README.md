# Episode 3: Harness Delegate & Connectors

## 🎯 Goal
Install the Delegate (messenger) and connect Harness to all your tools.
Like plugging in all the cables before turning on your gaming PC.

---

## 📚 Topics Covered

### 1. Delegate Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│   HARNESS CLOUD (SaaS)                                      │
│   ════════════════════                                       │
│   • Stores your pipelines                                   │
│   • Shows the UI/Dashboard                                  │
│   • Manages configurations                                  │
│                                                              │
│              ▲                                               │
│              │ (Outbound connection ONLY)                    │
│              │ (Delegate calls Harness, not reverse)         │
│              ▼                                               │
│                                                              │
│   YOUR NETWORK / INFRASTRUCTURE                             │
│   ═════════════════════════════                              │
│   ┌─────────────────────────────┐                           │
│   │      DELEGATE               │                           │
│   │                             │                           │
│   │  • Runs tasks from Harness  │                           │
│   │  • Deploys to your servers  │                           │
│   │  • Runs builds              │                           │
│   │  • Executes scripts         │                           │
│   └─────────────────────────────┘                           │
│              │                                               │
│              ├────→ Kubernetes Cluster                       │
│              ├────→ AWS Services                             │
│              ├────→ Docker Registry                          │
│              └────→ Any server in your network              │
│                                                              │
└─────────────────────────────────────────────────────────────┘

KEY POINT: Delegate makes OUTBOUND calls to Harness.
           No inbound ports needed = MORE SECURE!
```

---

### 2. Types of Delegates

| Type | Where it runs | Best for |
|------|--------------|----------|
| **Kubernetes Delegate** | K8s cluster | Production (recommended) |
| **Docker Delegate** | Any Docker host | Development/Testing |
| **VM Delegate** | Linux/Windows VM | Legacy systems |

```
Recommendation:
═══════════════
Development → Docker Delegate (quick setup)
Production  → Kubernetes Delegate (scalable, reliable)
Legacy      → VM Delegate (for old servers)
```

---

### 3. Kubernetes Delegate (Recommended)

```
┌─────────────────────────────────────────┐
│  Kubernetes Delegate                     │
│  ════════════════════                    │
│                                          │
│  Runs as: Kubernetes Deployment          │
│  Namespace: harness-delegate-ng          │
│  Resources:                              │
│    CPU: 0.5 - 1 core                    │
│    Memory: 2GB - 4GB                     │
│  Replicas: 1 (can scale to more)        │
│                                          │
│  What it needs:                          │
│  • Kubernetes cluster (any: EKS, GKE,   │
│    AKS, minikube, kind)                  │
│  • Internet access (to call Harness)     │
│  • kubectl configured                    │
│                                          │
└─────────────────────────────────────────┘
```

---

### 4. Docker Delegate

```
┌─────────────────────────────────────────┐
│  Docker Delegate                         │
│  ═══════════════                         │
│                                          │
│  Runs as: Docker container               │
│  Image: harness/delegate:latest          │
│  Resources:                              │
│    CPU: 0.5 core                         │
│    Memory: 2GB                           │
│                                          │
│  What it needs:                          │
│  • Docker installed                      │
│  • Internet access                       │
│                                          │
│  Best for: Quick testing, development    │
└─────────────────────────────────────────┘
```

---

### 5. Delegate Scaling & High Availability

```
Single Delegate (Development):
┌───────────┐
│ Delegate  │ ← If this dies, everything stops
└───────────┘

Multiple Delegates (Production):
┌───────────┐  ┌───────────┐  ┌───────────┐
│ Delegate  │  │ Delegate  │  │ Delegate  │
│    #1     │  │    #2     │  │    #3     │
└───────────┘  └───────────┘  └───────────┘
     │              │              │
     └──────────────┼──────────────┘
                    │
        If one dies, others take over!
        = HIGH AVAILABILITY (HA)
```

**Scaling Rules:**
- 1 Delegate = handles ~50 concurrent tasks
- 2+ Delegates = High Availability
- All Delegates with same name = automatic load balancing

---

### 6. Delegate Troubleshooting

| Problem | Solution |
|---------|----------|
| Delegate not connecting | Check internet access, firewall rules |
| Delegate keeps restarting | Increase memory (4GB minimum) |
| Tasks timing out | Check delegate has access to target |
| Delegate shows "expired" | Upgrade delegate image version |
| "No delegate available" | Check delegate is running and healthy |

**Troubleshooting Commands:**
```bash
# Check delegate pods
kubectl get pods -n harness-delegate-ng

# Check delegate logs
kubectl logs -f <delegate-pod-name> -n harness-delegate-ng

# Check delegate events
kubectl describe pod <delegate-pod-name> -n harness-delegate-ng
```

---

### 7. Connectors Deep Dive

#### GitHub Connector
```yaml
What: Connects Harness to your GitHub repos
Why:  So Harness can clone your code
Auth Options:
  - Personal Access Token (PAT) ← Recommended
  - GitHub App
  - OAuth
  
Permissions needed:
  - repo (full control)
  - admin:repo_hook (for webhooks/triggers)
```

#### Docker Hub Connector
```yaml
What: Connects to Docker Hub registry
Why:  Push/Pull Docker images
Auth:
  - Username + Password/Token
  
Get token:
  Docker Hub → Account Settings → Security → New Access Token
```

#### AWS Connector
```yaml
What: Connects to Amazon Web Services
Why:  Deploy to EKS, ECS, push to ECR
Auth Options:
  - Access Key + Secret Key
  - IAM Role (if delegate runs in AWS)
  - IRSA (IAM Roles for Service Accounts)

Permissions needed (for this course):
  - AmazonECR: Push/Pull images
  - AmazonEKS: Deploy to clusters
  - AmazonECS: Deploy services
```

#### Kubernetes Connector
```yaml
What: Connects to a Kubernetes cluster
Why:  Deploy applications
Auth Options:
  - Inherit from Delegate (easiest!)
  - Service Account Token
  - Client Certificate
  
If delegate runs IN the cluster:
  → Use "Inherit from Delegate" ← EASIEST
```

---

## 🖥️ Demo: Install Delegate on Kubernetes

### Prerequisites
- A Kubernetes cluster (minikube, kind, or EKS)
- kubectl configured and working

### Step 1: Get Delegate YAML from Harness

1. Go to **Project Settings** → **Delegates**
2. Click **+ New Delegate**
3. Choose **Kubernetes**
4. Fill in:
   - Name: `my-k8s-delegate`
   - Size: Small
5. Click **Download YAML**

### Step 2: The Delegate YAML (What You Get)

```yaml
# harness-delegate.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: harness-delegate-ng

---
apiVersion: v1
kind: Secret
metadata:
  name: my-k8s-delegate-account-token
  namespace: harness-delegate-ng
type: Opaque
data:
  DELEGATE_TOKEN: "<your-token-here>"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-k8s-delegate
  namespace: harness-delegate-ng
  labels:
    harness.io/name: my-k8s-delegate
spec:
  replicas: 1
  selector:
    matchLabels:
      harness.io/name: my-k8s-delegate
  template:
    metadata:
      labels:
        harness.io/name: my-k8s-delegate
    spec:
      containers:
        - name: delegate
          image: harness/delegate:latest
          env:
            - name: DELEGATE_NAME
              value: my-k8s-delegate
            - name: ACCOUNT_ID
              value: "<your-account-id>"
            - name: DELEGATE_TOKEN
              valueFrom:
                secretKeyRef:
                  name: my-k8s-delegate-account-token
                  key: DELEGATE_TOKEN
            - name: MANAGER_HOST_AND_PORT
              value: https://app.harness.io
            - name: DELEGATE_TYPE
              value: KUBERNETES
          resources:
            requests:
              memory: "2Gi"
              cpu: "0.5"
            limits:
              memory: "4Gi"
              cpu: "1"
```

### Step 3: Install the Delegate

```bash
# Apply the YAML to your cluster
kubectl apply -f harness-delegate.yaml

# Watch it start up
kubectl get pods -n harness-delegate-ng -w

# Expected output:
# NAME                              READY   STATUS    RESTARTS   AGE
# my-k8s-delegate-xxx-yyy           1/1     Running   0          60s
```

### Step 4: Verify in Harness

1. Go back to **Project Settings** → **Delegates**
2. Wait 1-2 minutes
3. You should see your delegate with status: **Connected** ✅

---

## 🖥️ Demo: Configure All Connectors

### Connector 1: GitHub — ✅ ALREADY DONE (Episode 1)

```
You already created this in Episode 1:
  Name: Github
  Level: Account
  URL: https://github.com/YOUR-USERNAME
  Auth: Personal Access Token
  Connectivity: Connect through Harness Platform
  Status: ● Success ✅
```

No action needed. Just verify it still works:
Project Settings → Connectors → click `Github` → Test → ✅

---

### Connector 2: Docker Hub — ✅ ALREADY DONE (Episode 2)

```
You already created this in Episode 2:
  Name: dockerhub
  Level: Account
  Provider: Docker Hub
  URL: https://index.docker.io/v2/
  Auth: Username + secret "docker-hub-password"
  Connectivity: Connect through Harness Platform
  Status: ● Success ✅
```

No action needed. Just verify it still works:
Account Settings → Connectors → click `dockerhub` → Test → ✅

---

### Connector 3: AWS — 🆕 CREATE NOW (Using OIDC — No Access Keys!)

**Why OIDC?** Access keys can be hacked if leaked. OIDC = Harness proves its identity to AWS directly. No keys stored anywhere!

**Step A: Create OIDC Provider in AWS**

1. Go to AWS Console → **IAM** → **Identity providers**
2. Click **Add provider**
3. Fill in:
   - Provider type: **OpenID Connect**
   - Provider URL: `https://app.harness.io/ng/api/oidc/account/YOUR_HARNESS_ACCOUNT_ID`
   - Click "Get thumbprint"
   - Audience: `sts.amazonaws.com`
4. Click **Add provider**

**How to find your Harness Account ID:**
```
Harness → Account Settings → Overview → Account ID
OR look in URL: app.harness.io/ng/account/XXXXXXXX/...
```

**Step B: Create IAM Role for Harness OIDC**

1. Go to **IAM** → **Roles** → **Create role**
2. Trusted entity: **Web identity**
3. Identity provider: select the one you just created (`app.harness.io/ng/api/oidc/account/...`)
4. Audience: `sts.amazonaws.com`
5. Click Next
6. Permissions: Select **AdministratorAccess**
7. Click Next
8. Role name: `harness-openid-connect-role`
9. Click **Create role**
10. Copy the Role ARN: `arn:aws:iam::YOUR_ACCOUNT_ID:role/harness-oidc-role`

**Step C: Create AWS Connector in Harness**

1. Go to **Account Settings** → **Connectors** → **+ New Connector**
2. Choose **AWS - Cloud Provider**
3. Screen 1 (Overview):
   - Name: `aws-connector`
4. Screen 2 (Credentials):
   - Select: **Use OIDC**
   - IAM Role: `arn:aws:iam::YOUR_ACCOUNT_ID:role/harness-oidc-role`
   - Test Region: `us-east-1`
5. Screen 3 (Backoff Strategy):
   - Keep defaults (Fixed Delay)
   - Click Continue
6. Screen 4 (Connectivity):
   - Select: **Connect through Harness Platform**
7. Screen 5 (Connection Test):
   - Click Test → ✅ Success

**Where this OIDC connector is used:**
- Episode 6, 7, 10: Deploying to EKS (Harness CD native steps)
- Episode 4+: Pushing images to ECR (BuildAndPushECR step)
- NOT used for Terraform CLI (Terraform needs access keys as env vars)

---

### Connector 4: Kubernetes — 🆕 CREATE LATER (Episode 6)

```
Not needed for Episode 3 (we use Docker Delegate, not Kubernetes).
We create this in Episode 6 when we deploy to Kubernetes.

When you create it:
  Name: k8s-connector
  Connection Type: Inherit from Delegate (easiest)
  Delegate: your K8s delegate
```

---

### Summary: What's Connected After Episode 3

| Connector | Name | Created in | Status |
|-----------|------|-----------|--------|
| GitHub | `Github` | Episode 1 | ✅ Working |
| Docker Hub | `dockerhub` | Episode 2 | ✅ Working |
| AWS | `aws-connector` | Episode 3 (optional) | ✅ or skip |
| Kubernetes | `k8s-connector` | Episode 6 (later) | ⏳ Not yet |

---

## ✅ Episode 3 Checklist

- [ ] Understand Delegate architecture (outbound only)
- [ ] Know the 3 types (K8s, Docker, VM)
- [ ] Understand scaling and HA concepts
- [ ] Installed a Kubernetes Delegate
- [ ] Delegate shows "Connected" in Harness
- [ ] Created GitHub connector
- [ ] Created Docker Hub connector
- [ ] Created AWS connector
- [ ] Created Kubernetes connector
- [ ] All connectors pass "Test Connection"

---

## 📝 Key Takeaways

1. **Delegate = Your agent inside your network** (Harness never reaches in directly)
2. **Always use Kubernetes Delegate for production** (scalable + HA)
3. **Connectors need a Delegate** to work (Delegate does the actual connecting)
4. **"Inherit from Delegate"** is the easiest K8s connector setup
5. **Test Connection** button = always verify your connectors work!

---

> 🎬 Next Episode: [Episode 4 - Build Your First Enterprise CI Pipeline](../Episode-04/README.md)