# Episode 11 (Bonus): Harness Code Repository, Feature Flags, CCM & SRM

## 🎯 Goal
Cover the remaining 4 Harness modules that complete the FULL platform.
One class — all 4 modules — hands-on demo for each.

---

## 📚 Modules Covered in This Episode

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  MODULE 1: Code Repository        (30 min)                          │
│  MODULE 2: Feature Flags           (30 min)                          │
│  MODULE 3: Cloud Cost Management   (30 min)                          │
│  MODULE 4: Service Reliability     (30 min)                          │
│                                                                      │
│  Total: ~2 hours                                                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

---

## MODULE 1: Harness Code Repository

### What is it?

```
┌─────────────────────────────────────────────────────────────────────┐
│  HARNESS CODE REPOSITORY                                             │
│  ════════════════════════                                            │
│                                                                      │
│  Think of it as: GitHub/GitLab but INSIDE Harness                   │
│                                                                      │
│  Why?                                                                │
│  • Everything in ONE platform (code + pipelines + deploy)           │
│  • No need for separate GitHub/GitLab account                       │
│  • Built-in branch protection rules                                 │
│  • Code reviews integrated with pipelines                           │
│  • Security & governance with branch rules                          │
│                                                                      │
│  When to use:                                                        │
│  • Small teams wanting simplicity (one tool for everything)         │
│  • Companies that don't want to pay for GitHub Enterprise           │
│  • When you want tight integration between code and CI/CD          │
│                                                                      │
│  When NOT to use:                                                    │
│  • Already using GitHub/GitLab and happy with it                    │
│  • Large open-source projects (GitHub has bigger community)         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Features

```
┌─────────────────────────────────────────────────────────┐
│  FEATURES:                                               │
│                                                          │
│  ✅ Git repository hosting                               │
│  ✅ Branch protection rules                              │
│  ✅ Pull Requests with code review                       │
│  ✅ Merge strategies (squash, rebase, merge)            │
│  ✅ Webhooks and triggers                                │
│  ✅ Search across repositories                           │
│  ✅ Repository-level RBAC                                │
│  ✅ Integrated with Harness CI/CD (zero config!)        │
│  ✅ Security scanning on PRs                             │
│  ✅ Branch rules enforcement                             │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Demo: Create a Repository in Harness Code

```
STEPS:
═════

1. Left sidebar → Click "Code Repository"
2. Click "+ New Repository"
3. Fill in:
   ┌─────────────────────────────────────────────────┐
   │  Name: my-first-harness-repo                     │
   │  Description: Testing Harness Code Repository    │
   │  Visibility: Private                             │
   │  Initialize with README: ✅                      │
   │  Default Branch: main                            │
   │  License: (optional)                             │
   │  .gitignore: Java                                │
   └─────────────────────────────────────────────────┘
4. Click "Create Repository"

5. Clone it locally:
   git clone https://git.harness.io/ACCOUNT/ORG/PROJECT/my-first-harness-repo.git

6. Push code:
   cd my-first-harness-repo
   # add your files
   git add .
   git commit -m "First commit"
   git push

7. Create a branch:
   git checkout -b feature/add-hello
   # make changes
   git push -u origin feature/add-hello

8. Create Pull Request in Harness UI:
   → Code → your repo → Pull Requests → + New PR
   → Source: feature/add-hello
   → Target: main
   → Add reviewers → Submit

9. After approval → Merge PR
```

### Using Harness Code Repo as Pipeline Source

```yaml
# When using Harness Code Repository, the pipeline setup is simpler:
# No external connector needed!

pipeline:
  properties:
    ci:
      codebase:
        connectorRef: account.harnessCode  # Built-in! No setup!
        repoName: my-first-harness-repo
        build: <+input>
```

---

---

## MODULE 2: Feature Flags (FF)

### What is it?

```
┌─────────────────────────────────────────────────────────────────────┐
│  FEATURE FLAGS                                                       │
│  ═════════════                                                       │
│                                                                      │
│  Think of it as: A LIGHT SWITCH for features in your app            │
│                                                                      │
│  WITHOUT Feature Flags:                                              │
│  Want to show new button to users?                                  │
│  → Deploy new code → ALL users see it → If broken, redeploy ❌     │
│                                                                      │
│  WITH Feature Flags:                                                 │
│  Want to show new button to users?                                  │
│  → Deploy code with flag OFF → Nobody sees it                       │
│  → Turn flag ON for 5% of users → Test with small group            │
│  → Everything good? → Turn ON for 100%                              │
│  → Something wrong? → Turn OFF instantly (no redeploy!)             │
│                                                                      │
│  ANALOGY:                                                            │
│  Feature Flag = TV remote control                                   │
│  Feature = A TV channel                                              │
│  You can turn channels on/off WITHOUT rebuilding the TV!            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Use Cases

```
┌─────────────────────────────────────────────────────────┐
│  REAL-WORLD USE CASES:                                   │
│                                                          │
│  1. GRADUAL ROLLOUT                                      │
│     New checkout page → Show to 10% → then 50% → 100%  │
│                                                          │
│  2. A/B TESTING                                          │
│     Button color: 50% see BLUE, 50% see GREEN           │
│     → Which gets more clicks? Use that one.             │
│                                                          │
│  3. KILL SWITCH                                          │
│     Feature causing crashes? → Turn OFF in 1 second     │
│     No redeployment needed!                              │
│                                                          │
│  4. BETA TESTING                                         │
│     Show new feature ONLY to premium users               │
│                                                          │
│  5. DARK LAUNCHING                                       │
│     Deploy code to production but hidden from users     │
│     Test in production without risk                      │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Demo: Create and Use a Feature Flag

#### Step 1: Create Flag in Harness

```
1. Left sidebar → Click "Feature Flags"
2. Click "+ New Feature Flag"
3. Fill in:
   ┌─────────────────────────────────────────────────┐
   │  Name: new_checkout_page                         │
   │  Type: Boolean (on/off)                          │
   │  Description: Shows new checkout page to users   │
   │  Tags: frontend, checkout                        │
   └─────────────────────────────────────────────────┘
4. Click "Create"
5. Default state: OFF (nobody sees it yet)
```

#### Step 2: Add SDK to Your Application

```java
// Java Spring Boot Example
// Add dependency to pom.xml:
// <dependency>
//   <groupId>io.harness</groupId>
//   <artifactId>ff-java-server-sdk</artifactId>
//   <version>1.3.0</version>
// </dependency>

import io.harness.cf.client.api.*;
import io.harness.cf.client.dto.*;

@RestController
public class CheckoutController {

    private CfClient cfClient;

    @PostConstruct
    public void init() {
        cfClient = new CfClient(
            "YOUR_SDK_KEY",  // Get from Harness FF → Environments → SDK Key
            Config.builder().build()
        );
        cfClient.waitForInitialization();
    }

    @GetMapping("/checkout")
    public String checkout(@RequestParam String userId) {

        // Check if flag is ON for this user
        Target target = Target.builder()
            .identifier(userId)
            .name(userId)
            .build();

        boolean showNewCheckout = cfClient.boolVariation(
            "new_checkout_page",  // flag name
            target,
            false  // default if flag not found
        );

        if (showNewCheckout) {
            return "NEW checkout page! 🆕";
        } else {
            return "Old checkout page";
        }
    }
}
```

#### Step 3: Turn Flag ON for Specific Users

```
In Harness UI:
1. Feature Flags → new_checkout_page
2. Click "Add Targeting Rule"
3. Rule: "If user is in group 'beta-testers' → Serve TRUE"
4. For everyone else → Serve FALSE

OR: Percentage rollout:
   10% of users → TRUE (see new page)
   90% of users → FALSE (see old page)
```

---

---

## MODULE 3: Cloud Cost Management (CCM)

### What is it?

```
┌─────────────────────────────────────────────────────────────────────┐
│  CLOUD COST MANAGEMENT (CCM)                                         │
│  ═══════════════════════════                                         │
│                                                                      │
│  Think of it as: A MONEY TRACKER for your cloud bill                │
│                                                                      │
│  PROBLEM:                                                            │
│  Company gets AWS bill: $50,000/month 😱                            │
│  Nobody knows WHY it's so high                                      │
│  Nobody knows WHICH team is spending the most                       │
│  Nobody knows what to TURN OFF                                      │
│                                                                      │
│  SOLUTION (CCM):                                                     │
│  → Shows exactly where every dollar goes                            │
│  → "Team A spends $20K on EC2 instances running 24/7"              │
│  → "These 15 instances are idle at night — save $5K/month"          │
│  → Auto-stop idle resources when nobody is using them              │
│                                                                      │
│  ANALOGY:                                                            │
│  CCM = Your electricity bill broken down by room                    │
│  "Living room uses 40%, bedroom 20%, kitchen 30%, ghost 10%"       │
│  → Turn off the ghost (idle resources)! Save money!                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Features

```
┌─────────────────────────────────────────────────────────┐
│  CCM FEATURES:                                           │
│                                                          │
│  1. COST VISIBILITY                                      │
│     → Dashboard showing spend by service/team/project   │
│     → Daily, weekly, monthly trends                     │
│     → Cost by Kubernetes namespace/workload             │
│                                                          │
│  2. COST ANOMALY DETECTION                               │
│     → AI detects unusual spending spikes                │
│     → Alert: "EKS cost jumped 300% today!"             │
│                                                          │
│  3. AUTO-STOPPING                                        │
│     → Automatically stop dev/test resources at night    │
│     → Auto-start when someone accesses them            │
│     → Save 60-70% on non-prod environments             │
│                                                          │
│  4. BUDGETS & ALERTS                                     │
│     → Set budget: "Team A max $10K/month"              │
│     → Alert at 80%: "You've used $8K of $10K budget"   │
│                                                          │
│  5. RECOMMENDATIONS                                      │
│     → "Downsize this EC2 from m5.2xlarge to m5.large"  │
│     → "Use spot instances for batch jobs"              │
│     → "This EBS volume is unused — delete it"          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Demo: Set Up CCM

```
STEPS:
═════

1. Left sidebar → Click "Cloud Cost Management"
2. Click "Get Started"
3. Connect your cloud account:

   ┌─────────────────────────────────────────────────┐
   │  Select Cloud Provider:                           │
   │                                                   │
   │  ┌─────┐  ┌─────┐  ┌─────┐                     │
   │  │ AWS │  │Azure│  │ GCP │                     │
   │  └─────┘  └─────┘  └─────┘                     │
   │  ↑ Select your cloud                             │
   └─────────────────────────────────────────────────┘

4. For AWS:
   → Create a Cost & Usage Report (CUR) in AWS
   → Provide S3 bucket name where CUR is stored
   → Add cross-account IAM role for Harness to read billing

5. Wait 24 hours → CCM starts showing cost data

6. Explore:
   → Overview: Total spend, trends, top services
   → Perspectives: Cost by team, project, service
   → Anomalies: Unusual spending spikes
   → Recommendations: Where to save money
   → AutoStopping: Set up idle resource stopping
```

### AutoStopping Example

```
┌─────────────────────────────────────────────────────────┐
│  AUTO-STOPPING RULE:                                     │
│                                                          │
│  Name: "Stop Dev EKS at Night"                          │
│  Resource: EKS cluster "dev-cluster"                    │
│  Rule: Stop when idle for 30 minutes                    │
│  Schedule: Stop at 8 PM, Allow start from 7 AM          │
│                                                          │
│  SAVINGS:                                                │
│  Before: $720/month (running 24/7)                      │
│  After:  $240/month (running 8 AM - 8 PM only)         │
│  Saved:  $480/month = $5,760/year! 💰                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

---

## MODULE 4: Service Reliability Management (SRM)

### What is it?

```
┌─────────────────────────────────────────────────────────────────────┐
│  SERVICE RELIABILITY MANAGEMENT (SRM)                                │
│  ════════════════════════════════════                                │
│                                                                      │
│  Think of it as: A HEALTH REPORT CARD for your services             │
│                                                                      │
│  PROBLEM:                                                            │
│  "Is our app reliable enough for customers?"                        │
│  "How often does it break?"                                         │
│  "When should we stop adding features and fix reliability?"         │
│                                                                      │
│  SOLUTION (SRM):                                                     │
│  → Define SLOs (Service Level Objectives)                           │
│    Example: "99.9% uptime" or "Response time < 200ms"              │
│  → Track error budgets                                              │
│    Example: "You've used 60% of your error budget this month"      │
│  → Alert before SLOs are breached                                   │
│  → Decide: ship features vs fix reliability                        │
│                                                                      │
│  ANALOGY:                                                            │
│  SRM = Your health checkup                                          │
│  SLO = "Blood pressure should be below 120/80"                     │
│  Error Budget = "You can eat junk food 3 times this month"         │
│  If budget exhausted = "Stop junk food, focus on health!"          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Concepts

```
┌─────────────────────────────────────────────────────────┐
│  SLI (Service Level Indicator):                          │
│  → The METRIC you measure                               │
│  → Example: "Success rate of API calls"                 │
│  → Example: "Latency of /checkout endpoint"             │
│                                                          │
│  SLO (Service Level Objective):                          │
│  → The TARGET you want to hit                           │
│  → Example: "99.9% success rate per month"              │
│  → Example: "95% of requests < 200ms"                   │
│                                                          │
│  Error Budget:                                           │
│  → How much FAILURE you can tolerate                    │
│  → 99.9% uptime = 0.1% allowed downtime                │
│  → 0.1% of 30 days = 43.2 minutes of downtime/month    │
│  → Used 30 min already? Only 13 min left this month!   │
│                                                          │
│  SLA (Service Level Agreement):                          │
│  → EXTERNAL promise to customers (contractual)          │
│  → "We guarantee 99.9% uptime or refund"               │
│  → SLO should be STRICTER than SLA                      │
│    (internal target > external promise)                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Demo: Create an SLO in Harness

```
STEPS:
═════

1. Left sidebar → Click "Service Reliability"
2. Click "Monitored Services" → "+ New Monitored Service"
3. Fill in:
   ┌─────────────────────────────────────────────────┐
   │  Service: harness-course-app                      │
   │  Environment: production                          │
   │  Health Source: Prometheus                        │
   │  Prometheus URL: http://prometheus:9090           │
   └─────────────────────────────────────────────────┘

4. Click "SLOs" → "+ New SLO"
5. Fill in:
   ┌─────────────────────────────────────────────────┐
   │  Name: API Success Rate                          │
   │  Type: Availability                              │
   │  SLI Metric:                                     │
   │    Good events: http_requests_total{status="2xx"}│
   │    Total events: http_requests_total             │
   │  Target: 99.9%                                   │
   │  Period: Rolling 30 days                         │
   └─────────────────────────────────────────────────┘

6. Dashboard shows:
   ┌─────────────────────────────────────────────────┐
   │  SLO: API Success Rate                            │
   │                                                   │
   │  Current: 99.95%  ✅ (above 99.9% target)       │
   │  Error Budget Remaining: 72%                     │
   │  Error Budget Remaining Time: 31 min             │
   │                                                   │
   │  Status: HEALTHY 🟢                              │
   │                                                   │
   │  ┌───────────────────────────────────────┐       │
   │  │ ▁▁▁▁▁▁▁▁▁▁▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁   │       │
   │  │ Error budget burn rate (low = good)    │       │
   │  └───────────────────────────────────────┘       │
   └─────────────────────────────────────────────────┘
```

### When to Act on Error Budget

```
┌─────────────────────────────────────────────────────────┐
│  ERROR BUDGET POLICY:                                    │
│                                                          │
│  Budget > 50% remaining:  🟢 Ship new features freely  │
│  Budget 25-50% remaining: 🟡 Slow down, fix some bugs  │
│  Budget < 25% remaining:  🔴 STOP features, fix only   │
│  Budget exhausted (0%):   ⛔ Freeze all deployments!   │
│                                                          │
│  This helps teams BALANCE:                               │
│  • Moving fast (new features) vs                        │
│  • Staying reliable (fixing bugs)                       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

---

## ✅ Episode 11 Checklist

- [ ] Understand Harness Code Repository and when to use it
- [ ] Created a repo in Harness Code
- [ ] Know how to push code and create PRs
- [ ] Understand Feature Flags concept (light switch for features)
- [ ] Created a feature flag in Harness
- [ ] Know how to add FF SDK to Java app
- [ ] Understand percentage rollout and targeting rules
- [ ] Understand Cloud Cost Management purpose
- [ ] Know AutoStopping and how it saves money
- [ ] Understand SLI, SLO, SLA, and Error Budget
- [ ] Created an SLO in Harness SRM
- [ ] Know when to ship features vs fix reliability

---

## 📝 Key Takeaways

```
1. CODE REPOSITORY = GitHub inside Harness (simpler integration)
2. FEATURE FLAGS   = On/off switch for features WITHOUT redeploying
3. CCM             = Find and stop cloud money waste (save 30-70%)
4. SRM             = Track reliability with SLOs and error budgets
```

---

## 🗂️ Updated Course Structure

```
Episode 1:   Introduction to Harness & Enterprise CI/CD
Episode 2:   Harness Fundamentals
Episode 3:   Harness Delegate & Connectors
Episode 4:   Build Your First Enterprise CI Pipeline
Episode 5:   Advanced CI & DevSecOps
Episode 6:   Continuous Delivery to Kubernetes
Episode 7:   Helm, Amazon EKS & Amazon ECS Deployment
Episode 8:   Enterprise Security & Governance
Episode 9:   GitOps & Observability
Episode 10:  Complete Enterprise Project (End-to-End)
Episode 11:  Bonus - Code Repo, Feature Flags, CCM & SRM  ← NEW
```

---

> 🎬 Full course complete! Go back to [Course Overview](../README.md)
