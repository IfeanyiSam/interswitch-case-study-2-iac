# Infrastructure as Code (IaC) Pipeline

## Overview
Automated Terraform pipeline with environment-specific deployments, security scanning, and approval workflows.

## Pipeline Flow

### 1. Environment Detection
- Detects which environment folder was modified (`dev/`, `staging/`, `production/`)
- Only one environment can be changed per PR

### 2. Terraform Planning
- Retrieves secrets from HashiCorp Vault
- Validates Terraform configuration
- Runs security scans (Terrascan, OPA policies)
- Generates deployment plan

### 3. Deployment
- **Dev**: Auto-deploys immediately
- **Staging/Production**: Requires manual approval
  - Comment `approved` on the GitHub issue to deploy
  - Auto-merges PR after successful deployment

## Usage

### Making Changes
1. Create PR with changes to single environment folder
2. Pipeline automatically detects target environment
3. Review terraform plan in PR comments
4. For staging/production: approve via GitHub issue

### Approval Process
- Manual approval action creates GitHub issue
- Comment `approved` on the issue (not PR) to proceed
- Pipeline continues and deploys infrastructure

## Structure
```
environments/
├── dev/           # Development environment
├── staging/       # Staging environment  
└── production/    # Production environment

modules/
└── vpc/           # Reusable VPC module

policies/
└── security.rego  # OPA compliance policies
```

## Security Features
- **Vault Integration**: Centralized secret management
- **Policy Enforcement**: OPA validates infrastructure compliance
- **Security Scanning**: Terrascan identifies vulnerabilities
- **Approval Gates**: Production and Staging require manual approval

## Tools Used
- **Terraform**: Infrastructure provisioning
- **HashiCorp Vault**: Secret management
- **GitHub Actions**: Pipeline automation
- **Terrascan**: Security scanning
- **OPA**: Policy enforcement