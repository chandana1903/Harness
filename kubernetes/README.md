# Kubernetes Infrastructure (Terraform + GitHub Actions)

## What This Creates

```
AWS Infrastructure:
├── VPC (with public + private subnets)
├── EKS Cluster (Auto Mode, HA, Auto-scaling)
├── Bastion Server (EC2 - to access EKS)
│   ├── IAM Role with Admin access attached
│   ├── Harness Delegate installed
│   └── kubectl configured to access EKS
├── S3 Bucket (Terraform state - created manually)
└── IAM OIDC (GitHub Actions authenticates to AWS)

GitHub Actions:
├── Manual trigger with options:
│   ├── Plan (preview changes)
│   ├── Apply (create infrastructure)
│   └── Destroy (delete EVERYTHING, bill = $0)
└── Uses OpenID Connect (no AWS keys stored!)
```

---

## How to Set Up OIDC (GitHub → AWS — No Access Keys!)

**What is OIDC?**
```
Normal way: Store AWS_ACCESS_KEY_ID + SECRET in GitHub Secrets (RISKY!)
OIDC way:   GitHub proves its identity to AWS directly (NO keys stored!)
```

### Step 1: Create OIDC Provider in AWS

1. Go to AWS Console → **IAM** → **Identity providers**
2. Click **Add provider**
3. Fill in:
   - Provider type: **OpenID Connect**
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Click "Get thumbprint"
   - Audience: `sts.amazonaws.com`
4. Click **Add provider**

### Step 2: Create IAM Role for GitHub Actions

1. Go to **IAM** → **Roles** → **Create role**
2. Trusted entity type: **Web identity**
3. Identity provider: `token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Click Next
6. Permissions: Select **AdministratorAccess**
7. Click Next
8. Role name: `Harness-CI-CD-Zero-to-Hero-github-actions-role`
9. Click **Create role**

### Step 3: Edit Trust Policy (Restrict to Your Repo)

1. Go to the role → **Trust relationships** → **Edit trust policy**
2. Replace with:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR-GITHUB-USERNAME/Harness-CI-CD-Zero-to-Hero:*"
        }
      }
    }
  ]
}
```

3. Replace `YOUR_ACCOUNT_ID` with your 12-digit AWS account ID
4. Replace `YOUR-GITHUB-USERNAME` with your GitHub username
5. Click **Update policy**

### Step 4: Create S3 Bucket (Terraform State)

1. AWS Console → **S3** → **Create bucket**
2. Name: `harness-tf-state-harness-ci-cd-zero-to-hero` (globally unique)
3. Region: `us-east-1`
4. Versioning: ✅ Enable
5. Click **Create bucket**

### Step 5: Add GitHub Variables

GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **Variables**:

| Variable | Value |
|----------|-------|
| `AWS_REGION` | `us-east-1` |
| `AWS_ROLE_ARN` | `arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-role` |
| `S3_BUCKET_NAME` | `harness-tf-state-harness-ci-cd-zero-to-hero` |

### Step 6: Create GitHub Environment

1. GitHub repo → **Settings** → **Environments** → **New environment**
2. Name: `production`
3. Save

### Step 7: Run the Workflow

1. GitHub → **Actions** → **EKS Terraform**
2. Click **Run workflow** → Select `apply` → Run
3. Wait ~15 min → Cluster ready! ✅

### To Destroy (bill = $0):

1. Actions → EKS Terraform → Run workflow
2. Select: `destroy`
3. Confirm: type `yes`
4. Run → Everything deleted → $0

---

## Cost

```
Running:   ~$3.73/day (~$112/month)
Destroyed: $0.00 (only S3 bucket remains < $0.01/month)
```
