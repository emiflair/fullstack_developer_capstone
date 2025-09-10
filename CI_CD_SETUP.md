# CI/CD Pipeline Setup Guide

This guide explains how to set up the complete Continuous Integration and Continuous Deployment pipeline for the Fullstack Developer Capstone project.

## Overview

The CI/CD pipeline includes:
- **Continuous Integration**: Code linting, testing, security scanning
- **Continuous Deployment**: Automated deployment to Kubernetes cluster

## Pipeline Stages

### 1. Code Quality (CI)
- **Lint Python Files**: Uses flake8 to check Python code standards
- **Lint JavaScript Files**: Uses eslint for React and Node.js code
- **Run Tests**: Executes unit tests for both Python and JavaScript

### 2. Build & Security (CI)
- **Build Docker Image**: Creates containerized application
- **Security Scan**: Uses Trivy to scan for vulnerabilities
- **Upload Results**: Security findings sent to GitHub Security tab

### 3. Deploy (CD)
- **Deploy to Kubernetes**: Automated deployment to IBM Cloud Kubernetes
- **Health Checks**: Verifies application is running correctly
- **Rollback**: Automatic rollback if deployment fails

## Required Secrets

To enable the CD pipeline, add these secrets to your GitHub repository:

### GitHub Repository Settings > Secrets and Variables > Actions

1. **IBM_CLOUD_API_KEY**
   - Value: Your IBM Cloud API key
   - Purpose: Authenticate with IBM Cloud services

2. **CLUSTER_NAME**
   - Value: Your Kubernetes cluster name
   - Purpose: Target cluster for deployment

3. **REGISTRY_NAMESPACE** (optional - already in env variables)
   - Value: sn-labs-emifeaustin0
   - Purpose: IBM Container Registry namespace

## Setup Instructions

### 1. Get IBM Cloud API Key
```bash
# Login to IBM Cloud
ibmcloud login

# Create API key
ibmcloud iam api-key-create github-actions-key --description "API key for GitHub Actions"
```

### 2. Get Cluster Name
```bash
# List your clusters
ibmcloud ks clusters

# Use the cluster name in GitHub secrets
```

### 3. Add Secrets to GitHub
1. Go to your repository on GitHub
2. Click Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Add each secret with the values from above

### 4. Configure Environment Protection (Optional)
1. Go to Settings > Environments
2. Create "production" environment
3. Add protection rules (required reviewers, branch restrictions)

## Workflow Triggers

The pipeline runs on:
- **Push** to main, containerize-k8s, or containerize-k8s1 branches
- **Pull Request** to main branch

## Pipeline Flow

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Code      │    │    Lint      │    │    Test     │
│   Push      │───▶│   Python     │───▶│   Python    │
│             │    │   JavaScript │    │   JavaScript│
└─────────────┘    └──────────────┘    └─────────────┘
                           │                     │
                           ▼                     ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Deploy    │◀───│    Build     │◀───│   Security  │
│ Kubernetes  │    │   Docker     │    │    Scan     │
│             │    │   Image      │    │             │
└─────────────┘    └──────────────┘    └─────────────┘
```

## Monitoring

- **GitHub Actions**: View workflow runs in the Actions tab
- **Security**: Check Security tab for vulnerability reports
- **Kubernetes**: Monitor deployments with kubectl

## Troubleshooting

### Common Issues

1. **Secret Not Found**
   - Verify secrets are added to GitHub repository
   - Check secret names match exactly

2. **IBM Cloud Login Failed**
   - Verify API key is valid
   - Check IBM Cloud region is correct

3. **Deployment Failed**
   - Check Kubernetes cluster is running
   - Verify container registry permissions

### Debug Commands

```bash
# Check cluster status
kubectl get nodes

# Check deployment status  
kubectl get deployments

# View deployment logs
kubectl logs deployment/dealership-app

# Check service status
kubectl get services
```

## Benefits

- **Automated Quality**: Every commit is tested and scanned
- **Fast Feedback**: Developers know immediately if changes break anything
- **Secure Deployments**: Security scans prevent vulnerable code from reaching production
- **Zero Downtime**: Rolling updates ensure application stays available
- **Audit Trail**: Complete history of deployments and changes

## Next Steps

1. Push code to trigger first pipeline run
2. Monitor the Actions tab for results
3. Set up monitoring and alerting for production
4. Consider adding integration tests
5. Add database migration steps if needed
