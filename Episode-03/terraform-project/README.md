# Terraform Project — Create AWS Infrastructure from Harness Pipeline

## What This Does

```
Run pipeline → Choose "apply" → Creates VPC + EC2 in AWS
Run pipeline → Choose "destroy" → Deletes everything, bill = $0
```

No Delegate needed. Uses Harness Cloud.

---

## How It Works (The Flow)

```
GitHub (stores your Terraform code)
    ↓
Harness (clones code using GitHub connector)
    ↓
Terraform (reads main.tf from cloned code)
    ↓
AWS (creates VPC + EC2 using access key credentials)
```

---

## What Gets Created in AWS

```
VPC (10.0.0.0/16)
├── Internet Gateway
├── Public Subnet (10.0.1.0/24)
├── Route Table (internet access)
├── Security Group (all ports open)
└── EC2 Instance (t2.micro, Amazon Linux 2023)
```

---

## Setup — Do These ONCE Before Running

---

### Step 1: Create S3 Bucket (Terraform State)

1. Go to AWS Console → S3 → Create bucket
2. Fill in:
   - Bucket name: `harness-terraform-project` (or any unique name)
   - Region: `us-east-1`
   - Versioning: Enable ✅
3. Click Create bucket

---

### Step 2: Get AWS Access Key + Secret Key

1. Go to AWS Console → IAM → Users
2. Click your user → Security credentials tab
3. Click "Create access key"
4. Select "Command Line Interface (CLI)"
5. Copy:
   - Access key ID: `AKIA...`
   - Secret access key: `wJalr...`

---

### Step 3: Add Secrets in Harness

Go to Project Settings → Secrets → + New Secret → Text

**Secret 1:**
- Name: `aws_access_key_id`
- Value: paste Access Key ID
- Save

**Secret 2:**
- Name: `aws_secret_access_key`
- Value: paste Secret Access Key
- Save

---

### Step 4: Add Variables in Harness

Go to Project Settings → Variables → + New Variable

**Variable 1:**
- Name: `s3_bucket_name`
- Value: `harness-terraform-project` (your bucket name from Step 1)
- Save

**Variable 2:**
- Name: `aws_region`
- Value: `us-east-1`
- Save

---

### Step 5: Import Pipeline in Harness

1. Pipelines → Import from Git
2. Connector: Github
3. Repo: Harness-CI-CD-Zero-to-Hero
4. Branch: master
5. YAML Path: `Episode-03/terraform-project/.harness/pipeline-terraform.yaml`
6. Click Import

---

## How to Run

### CREATE infrastructure:
1. Click Run → tf_action: select `apply` → Run Pipeline
2. Wait 2-3 minutes
3. Output shows VPC ID + EC2 Public IP ✅

### DESTROY infrastructure:
1. Click Run → tf_action: select `destroy` → Run Pipeline
2. Wait 1-2 minutes
3. Output shows "DESTROYED! Bill = $0" ✅

---

## Where is the State File?

```
S3 bucket: harness-terraform-project
Path: harness-demo/terraform.tfstate

Terraform uses this to track what it created.
Destroy reads this to know what to delete.
```

---

## Cost

```
Running: $0 (t2.micro = free tier, 750 hours/month)
Destroyed: $0
```

---

## Summary

| What | Where | How |
|------|-------|-----|
| S3 bucket | AWS Console → S3 | Create manually once |
| Secret `aws_access_key_id` | Harness → Secrets | Your AWS Access Key ID |
| Secret `aws_secret_access_key` | Harness → Secrets | Your AWS Secret Key |
| Variable `s3_bucket_name` | Harness → Variables | Your bucket name |
| Variable `aws_region` | Harness → Variables | `us-east-1` |

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| "no valid credential sources" | Check secrets `aws_access_key_id` and `aws_secret_access_key` exist and are correct |
| "S3 bucket does not exist" | Create the bucket in AWS first (Step 1) |
| "Access Denied" | Your AWS user needs AdministratorAccess or EC2+VPC+S3 permissions |
| "Unsupported Terraform version" | Harness Cloud has Terraform 1.3.0, keep `required_version >= 1.3.0` |
| Destroy says "no state" | Must apply first before you can destroy |
