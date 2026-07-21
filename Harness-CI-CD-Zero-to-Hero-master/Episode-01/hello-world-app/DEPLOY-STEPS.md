# 🚀 Deploy Hello World in Harness — Step by Step

## What We Are Doing

We will push code to GitHub, then tell Harness to build it automatically.

---

## Step 1: Push Code to GitHub

Open terminal and run:

```bash
cd "Harness-CI-CD-Zero-to-Hero"
git add .
git commit -m "Hello World app"
git push origin master
```

Now your code is on GitHub. Harness will read it from there.

---

## Step 2: Open Harness

1. Open browser
2. Go to https://app.harness.io
3. Login with your account
4. Click "Continuous Integration" on the left sidebar

---

## Step 3: Create a GitHub Connector (First Time Only)

This tells Harness where your code lives.

1. Go to Account Settings (bottom of left sidebar)
2. Click Connectors
3. Click + New Connector
4. Click GitHub
5. Fill in:
   - Name: `Github`
   - URL Type: Account
   - URL: `https://github.com/YOUR-USERNAME`
6. Click Continue
7. Authentication:
   - Username: your GitHub username
   - Token: click + New Secret
   - Secret Name: `github-pat`
   - Secret Value: paste your GitHub Personal Access Token
8. Click Continue
9. Select: Connect through Harness Platform
10. Click Save and Continue
11. Test shows green checkmark = done!

How to get GitHub token: GitHub > Settings > Developer settings > Personal access tokens > Generate new token > check "repo" > Generate > copy it

---

## Step 4: Create a Pipeline

1. Click Pipelines on the left sidebar
2. Click + Create a Pipeline
3. Fill in:
   - Name: `devpipeline`
   - Select: Remote
   - Select: Third-party Git provider
   - Git Connector: Github (the one you just created)
   - Repository: Harness-CI-CD-Zero-to-Hero
   - Branch: master
   - YAML Path: `Episode-01/hello-world-app/.harness/devpipeline.yaml`
4. Click Start

---

## Step 5: Add a Stage

1. Click the + button (Add Stage)
2. Select: Build
3. Fill in:
   - Stage Name: `dev`
   - Clone Codebase: keep it ON
   - Select: Third-party Git provider
   - Connector: Github
   - Repository Name: Harness-CI-CD-Zero-to-Hero
4. Click Set Up Stage

---

## Step 6: Select Infrastructure

1. You see 4 options: Cloud, Kubernetes, Local, VMs
2. Select: Cloud (needs credit card verification, no charge)
   - OR select Kubernetes/Local if you have a Delegate installed
3. Platform: Linux
4. Click Continue

---

## Step 7: Add a Build Step

1. Click + Add Step
2. Click Add Step
3. From Step Library, click Run (first option)
4. Fill in:
   - Name: `Run_1`
   - Shell: Sh
   - Command: paste this exactly:

```bash
echo "=== Building Hello World ==="
cd Episode-01/hello-world-app
mvn clean package -q
echo ""
echo "=== Running the App ==="
java -jar target/hello-world-1.0.0.jar
echo ""
echo "=== Pipeline Success! ==="
```

5. Leave Container Registry empty
6. Leave Image empty
7. Click Apply Changes

---

## Step 8: Save the Pipeline

1. Click Save (top right)
2. It saves to your GitHub repo automatically

---

## Step 9: Run the Pipeline

1. Click Run (top right)
2. Build Type: Git Branch
3. Branch Name: master
4. Click Run Pipeline

---

## Step 10: Watch It Run

Wait 1-2 minutes. You will see:

- Initialize: green checkmark
- Clone codebase: green checkmark
- Run_1: green checkmark

Click on Run_1 to see the output:

```
=== Building Hello World ===

=== Running the App ===
=================================
  Hello from Harness CI/CD! 🚀
  Episode 1 - First Pipeline Run
=================================

=== Pipeline Success! ===
```

Done! Your first Harness pipeline works! 🎉

---

## If It Fails — Common Fixes

| Error | Fix |
|-------|-----|
| Connector not found | Make sure connector name in YAML matches exactly what you created |
| No eligible delegates | Use "Cloud" infrastructure instead of Kubernetes/Local/VMs |
| MissingProjectException (no POM) | Add `cd Episode-01/hello-world-app` before `mvn clean package` |
| projectIdentifier does not match | Change `projectIdentifier` in YAML to match your Harness project ID (find it in the URL) |
| File already exists in GitHub | Use "Import from Git" instead of "Create Pipeline" |
| Credit card required for Cloud | Either add card (no charge) or install a Docker Delegate |

---

## Important: If You Have a Different Project Name

Open the YAML file and change these values to match YOUR Harness account:

```yaml
pipeline:
  name: YOUR-PIPELINE-NAME
  identifier: YOUR-PIPELINE-NAME
  projectIdentifier: YOUR-PROJECT-ID      # find in URL after /projects/
  orgIdentifier: default                   # usually "default"
  properties:
    ci:
      codebase:
        connectorRef: account.YOUR-CONNECTOR-NAME
        repoName: YOUR-GITHUB-REPO-NAME
```

---

## The Pipeline YAML (Complete Working File)

```yaml
pipeline:
  name: devpipeline
  identifier: devpipeline
  projectIdentifier: HarnessCICDZerotoHero
  orgIdentifier: default
  tags: {}
  properties:
    ci:
      codebase:
        connectorRef: account.Github
        build: <+input>
  stages:
    - stage:
        name: dev
        identifier: dev
        description: ""
        type: CI
        spec:
          cloneCodebase: true
          caching:
            enabled: true
            override: true
          buildIntelligence:
            enabled: true
          platform:
            os: Linux
            arch: Amd64
          runtime:
            type: Cloud
            spec: {}
          execution:
            steps:
              - step:
                  type: Run
                  name: Run_1
                  identifier: Run_1
                  spec:
                    shell: Sh
                    command: |-
                      echo "=== Building Hello World ==="
                      cd Episode-01/hello-world-app
                      mvn clean package -q
                      echo ""
                      echo "=== Running the App ==="
                      java -jar target/hello-world-1.0.0.jar
                      echo ""
                      echo "=== Pipeline Success! ==="
```

---

## What Just Happened (Simple)

```
You clicked Run
    ↓
Harness downloaded your code from GitHub
    ↓
Harness ran Maven to build the Java app
    ↓
Harness ran the app
    ↓
App printed "Hello from Harness CI/CD!"
    ↓
Pipeline finished successfully ✅
```

---

## Next Steps

- Episode 2: Learn how Harness is organized (Accounts, Projects, RBAC)
- Episode 3: Install Delegate and connect to AWS, Docker Hub
- Episode 4: Build a real CI pipeline with Docker image push
