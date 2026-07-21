# Episode 3: Docker Delegate on AWS EC2 + Go CI Pipeline

## 🎯 Goal
Install a Docker Delegate on AWS EC2 and run a Go CI pipeline.

---

## What We Build

```
AWS EC2 Instance (Amazon Linux 2023)
    ├── Docker installed
    ├── Harness Docker Delegate (with --network host)
    ├── Harness Docker Runner v0.1.20 (port 3000)

Pipeline (11 steps):
    Run Tests → Lint Check → Code Coverage → Build Binary
        → Verify App → Push to Docker Hub → Verify Push
            → Pipeline Complete → Verify Success
                → Wait 1 min → Delete Repo & Verify
```

---

## What You Need Before Starting

1. AWS Account (free tier works)
2. Harness account
3. GitHub connector already created (account.Github)
4. Docker Hub connector already created (dockerhub at project level)
5. Secret `docker-hub-password` created
6. Variable `docker_username` created

---

## Step 1: Create AWS EC2 Instance

1. Login to AWS Console: https://console.aws.amazon.com
2. Go to EC2 → Launch Instance
3. Fill in:
   - Name: `harness-delegate`
   - OS: Amazon Linux 2023 (free tier eligible)
   - Instance type: `t2.medium` (2 CPU, 4 GB RAM — minimum for delegate)
   - Key pair: Create new → name: `harness-key` → Download .pem file
   - Security Group: Allow SSH (port 22) from your IP
4. Click Launch Instance
5. Wait until status shows: Running ✅

---

## Step 2: Connect to EC2 via SSH

```bash
chmod 400 harness-key.pem
ssh -i harness-key.pem ec2-user@YOUR-EC2-PUBLIC-IP
```

You are now inside the EC2 machine. (Amazon Linux uses `ec2-user`, not `ubuntu`)

---

## Step 3: Install Docker on EC2

If you're using **Amazon Linux 2023**, don't use the Ubuntu/Debian `apt` commands. Use `dnf` instead.

```bash
# Update packages
sudo dnf update -y

# Install Docker
sudo dnf install -y docker

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify installation
docker --version
docker ps
```

If you want to run Docker **without sudo**:

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Apply the new group membership
newgrp docker

# Test
docker ps
```

If Docker isn't running, check its status:

```bash
sudo systemctl status docker
```

To restart Docker:

```bash
sudo systemctl restart docker
```

To verify the installation completely, run:

```bash
docker run hello-world
```
---

## Step 4: Install Harness Docker Delegate on EC2

**Important — When do you need what:**
```
CI Pipeline (build code)     → Uses Harness Cloud → No Delegate needed
CD Pipeline (deploy to K8s)  → Uses Delegate ONLY → No Runner needed → No --network host needed
CI with Docker Runner        → Delegate + Runner  → Needs --network host
```

```
CD Pipeline (deploy to K8s/ECS) → Delegate ONLY → No runner needed → Works without --network host
CI Pipeline (build code with Docker runner) → Delegate + Runner → Needs --network host
```

For this course:
- Episode 6+ CD pipeline uses this **Docker Delegate** (no runner, no --network host)

1. Go to Harness → Project Settings → Delegates → + New Delegate → Docker
2. Set Delegate Name: `ec2-docker-delegate`
3. Set Tags: `linux-amd64`
4. Copy the command from Harness and run on EC2:

```bash
docker run -d --network host --cpus=1 --memory=2g \
  -e DELEGATE_NAME=ec2-docker-delegate \
  -e NEXT_GEN="true" \
  -e DELEGATE_TYPE="DOCKER" \
  -e ACCOUNT_ID=YOUR_ACCOUNT_ID \
  -e DELEGATE_TOKEN=YOUR_TOKEN \
  -e DELEGATE_TAGS="linux-amd64" \
  -e MANAGER_HOST_AND_PORT=https://app.harness.io \
  us-docker.pkg.dev/gar-prod-setup/harness-public/harness/delegate:latest
```

**IMPORTANT:** `--network host` is required! Without it, the delegate container cannot reach the Docker Runner on localhost:3000.

5. Wait 2 minutes
6. Check Harness UI → Delegates → `ec2-docker-delegate` → **Connected** ✅

---

## Step 5: Install Harness Docker Runner on EC2

```bash
# Download the runner binary
curl -L -o harness-docker-runner \
https://github.com/harness/harness-docker-runner/releases/download/v0.1.20/harness-docker-runner-linux-amd64

# Make it executable
chmod +x harness-docker-runner

# (Optional) Move it to a system path
sudo mv harness-docker-runner /usr/local/bin/

# Verify installation
harness-docker-runner --version

# IMPORTANT: Set Docker API version (fixes "client version too new" error)
export DOCKER_API_VERSION=1.44

# Start the runner in the background
nohup harness-docker-runner server > runner.log 2>&1 &

# Check that the process is running
ps -ef | grep harness-docker-runner

# Check whether it is listening on port 3000
ss -lntp | grep 3000

# Verify the health endpoint
curl http://localhost:3000/healthz
```

If you see a response → Runner is ready! ✅

---

## Step 6: Install Auto-Upgrade (Optional)

```bash
docker run -d --cpus=0.1 --memory=100m \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e ACCOUNT_ID=YOUR_ACCOUNT_ID \
  -e MANAGER_HOST_AND_PORT=https://app.harness.io \
  -e UPGRADER_WORKLOAD_NAME=ec2-docker-delegate \
  -e UPGRADER_TOKEN=YOUR_TOKEN \
  -e CONTAINER_STOP_TIMEOUT=3600 \
  -e SCHEDULE="0 */1 * * *" harness/upgrader:latest
```

---

## Step 7: Verify Everything Running on EC2

```bash
# Check Docker containers
docker ps

# Expected output:
# CONTAINER ID   IMAGE                    STATUS       NAMES
# xxxx           harness/delegate         Up 5 min     (delegate)
# yyyy           harness/upgrader         Up 3 min     (upgrader)

# Check runner process
ps aux | grep harness-docker-runner
```

3 things running: Delegate + Upgrader + Runner ✅

---

## Step 9: Push Go Code to GitHub

On your laptop:
```bash
cd Harness-CI-CD-Zero-to-Hero
git add .
git commit -m "Episode 3: Go project with Docker Delegate"
git push origin master
```

---

## Step 10: Create Pipeline in Harness

1. Pipelines → Import from Git
2. Connector: Github
3. Repo: Harness-CI-CD-Zero-to-Hero
4. Branch: master
5. YAML Path: Episode-03/go-project/.harness/pipeline-docker-delegate.yaml
6. Click Import

---

## Step 11: Run the Pipeline!

1. Click Run
2. Branch: master
3. Click Run Pipeline
4. Watch 11 steps:
   - Run Tests ✅
   - Lint Check ✅
   - Code Coverage ✅
   - Build App ✅
   - Verify App ✅
   - Build and Push to Docker Hub ✅
   - Verify Push ✅
   - Pipeline Complete ✅
   - Verify Success ✅
   - Wait 1 minute ✅
   - Delete Docker Hub Repository & Verify ✅

---

## Expected Output

Step 1 (Run Tests):
```
=== PASS: TestHomeHandler (0.00s)
=== PASS: TestHealthHandler (0.00s)
=== All Tests Passed! ===
```

Step 5 (Verify App):
```
{"message":"Hello from Harness CI/CD Course!","episode":3,"language":"Go",...}
{"status":"healthy"}
=== App Verified! ===
```

Step 8 (Pipeline Complete):
```
=========================================
  PIPELINE COMPLETE!
  Image: yaswanth111/go-harness-app:1
=========================================
```

Step 11 (Delete & Verify):
```
Deleting repository: yaswanth111/go-harness-app
✅ Repository DELETED successfully!
=========================================
  ALL DONE! Repository cleaned up.
=========================================
```

---

## Project Structure

```
Episode-03/
├── README.md
└── go-project/
    ├── main.go                            ← Go web app (/ and /health)
    ├── main_test.go                       ← 2 unit tests
    ├── go.mod                             ← Go module
    ├── Dockerfile                         ← Multi-stage Docker build
    └── .harness/
        └── pipeline-docker-delegate.yaml  ← CI pipeline (11 steps)
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Failed to connect to port 3000" | Runner not running. Kill old: `fuser -k 3000/tcp`, restart: `export DOCKER_API_VERSION=1.44 && nohup harness-docker-runner server > runner.log 2>&1 &` |
| "client version 1.48 is too new" | Use runner v0.1.20 (not v0.1.25) AND set `export DOCKER_API_VERSION=1.44` before starting runner |
| "No eligible delegates" | Check delegate is running: `docker ps`. Restart if needed with `--network host` |
| "Non active delegates" | Delegate died. Restart Docker container with same command |
| "Connector not found" | Check connector name matches exactly in YAML |
| EC2 SSH timeout | Check security group allows port 22 from your IP |
| Docker pull fails on EC2 | Check EC2 has outbound internet (security group) |
| curl install fails (curl-minimal conflict) | Don't install curl. `curl-minimal` is pre-installed on Amazon Linux 2023 |

---

## Cost

- EC2 `t2.medium`: ~$0.046/hour = ~$1.10/day
- **Stop the instance when not using!**
- AWS Console → EC2 → Select instance → Instance State → Stop

---

## Key Takeaways

1. Docker Delegate = runs on any machine with Docker (EC2, laptop, anywhere)
2. Docker Runner = separate binary, listens on port 3000, executes pipeline containers
3. Delegate needs `--network host` to reach runner on localhost:3000
4. Runner v0.1.20 + `DOCKER_API_VERSION=1.44` for Amazon Linux 2023
5. Go builds are fast (entire pipeline ~3-5 minutes)

---

> 🎬 Next Episode: [Episode 4 - Build Your First Enterprise CI Pipeline](../Episode-04/README.md)
