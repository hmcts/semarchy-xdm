# Crime Standing Data Service - Semarchy XDM

Infrastructure as Code (IaC) repository for deploying the Crime Standing Data Service (CSDS) using Semarchy XDM on Azure.

## Overview

This repository contains Terraform configurations to deploy and manage the Crime Standing Data Service infrastructure on Azure. The service utilizes Semarchy XDM for master data management, running on Azure Container Apps with PostgreSQL Flexible Server as the backend database.

## Architecture

The infrastructure is composed of the following components:

### Core Infrastructure (`components/core/`)
- **Resource Group**: Primary resource group for all CSDS resources
- **Log Analytics Workspace**: Centralized logging and monitoring
- **Key Vault**: Secrets management for application credentials and configuration
- **Storage Account**: Blob storage for application data
- **Virtual Network**: Network isolation and security
- **Azure Functions**: Serverless compute for auxiliary tasks

### Container Apps (`components/container-app/`)
- **Active Container**: Primary Semarchy XDM instance running on dedicated workload profile
- **Passive Container**: Secondary Semarchy XDM instance for high availability
- **Custom Domains**: 
  - Active: `csds-active.{env}.platform.hmcts.net` (internal Azure network only)
  - Passive: `csds-passive.{env}.platform.hmcts.net` (internal Azure network only)
- **External Access**: Azure Front Door provides external access via:
  - Active: `csds.{env}.apps.hmcts.net`
  - Passive: `csds-passive.{env}.apps.hmcts.net`

> **Note**: The `*.platform.hmcts.net` domains are only accessible from within the Azure network. External access is configured through Azure Front Door using the `*.apps.hmcts.net` domains.

### Database (`components/database/`)
- **PostgreSQL Flexible Server**: Backend database for Semarchy XDM
- **High Availability**: Enabled in staging and production environments
- **Extensions**: UUID-OSSP, FuzzyStrMatch
- **Azure AD Authentication**: Integrated authentication for database access

### Data Factory (`components/datafactory/`)
- **Azure Data Factory**: Data integration and ETL workflows

## Directory Structure

```
.
├── components/              # Terraform modules for infrastructure components
│   ├── container-app/      # Azure Container Apps configuration
│   ├── core/               # Core infrastructure (networking, key vault, logging)
│   ├── database/           # PostgreSQL Flexible Server configuration
│   └── datafactory/        # Azure Data Factory configuration
├── environments/           # Environment-specific configuration
│   ├── dev/               # Development environment variables
│   ├── sbox/              # Sandbox environment variables
│   ├── stg/               # Staging environment variables
│   └── prod/              # Production environment variables
└── semarchy/              # Semarchy XDM application configuration files
```

## Environments

The infrastructure supports four environments:

- **dev**: Development environment for testing new features
- **sbox**: Sandbox environment for experimentation
- **stg**: Staging environment for pre-production validation
- **prod**: Production environment

## Deployment

### Automated Deployment

This repository follows a **trunk-based development workflow**. Changes merged to the `master` branch are automatically deployed to Azure via Azure DevOps pipelines.

**Important**: Do not manually apply Terraform configurations. All deployments are managed through the CI/CD pipeline.

### Pipeline Process

The Azure DevOps pipeline (`azure-pipelines.yml`) handles:
1. Terraform validation and formatting checks
2. Infrastructure plan generation
3. Automated deployment to the appropriate environment
4. Post-deployment verification

## Semarchy Configuration

The `semarchy/` directory contains Semarchy XDM application configuration files. These configurations are deployed alongside the infrastructure and may include:
- Application properties
- Environment-specific settings
- Custom model configurations
- Integration settings

## Prerequisites

For local development and testing:

- Terraform >= 1.0
- Azure CLI
- Pre-commit hooks (see Contributing section)
- Access to Azure subscription and appropriate permissions

## Contributing

We use pre-commit hooks for validating the terraform format and maintaining the documentation automatically.
Install it with:

```shell
$ brew install pre-commit
$ pre-commit install
```

If you add a new hook make sure to run it against all files:
```shell
$ pre-commit run --all-files --show-diff-on-failure
```

## Key Resources

- **Product**: Crime Standing Data Service (CSDS)
- **Business Area**: DTS (Digital Technology Services)
- **Semarchy Version**: 2025.1.9
- **PostgreSQL Version**: Configurable per environment
- **Container Image Registry**: Docker Hub (semarchy/xdm)
