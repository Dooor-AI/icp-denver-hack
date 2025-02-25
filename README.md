# ICP AI workflow powered by Akash with AMD SEV-SNP Attestation and EVM smart-contracts

<br/>
Creating a decentralized computation protocol focused on LLMs with ICP as orchestration layer. Currently connecting with Akash computing.
<br/>
<br/>
Demo Video 1: https://youtu.be/ZZQ3BS8VGfQ
<br/>

EVM Escrow DPL deployed on: [0xe2A4F6Cae191e6e599488E1e2C95861312Df9826](https://moonscan.io/address/0xe2A4F6Cae191e6e599488E1e2C95861312Df9826)
<br/>
ICP oracle hash: https://dashboard.internetcomputer.org/canister/bv7br-xyaaa-aaaam-ac4uq-cai - code at /oracle
<br/>

<br/>
Akash hash: https://atomscan.com/akash/accounts/akash1c3er49222vygzm6g4djr52muf3mspqam6cpqpy
Use the /DAO folder to deploy a dao capable to manage the modular protocol.
<br/>
<br/>
Documentation: https://dooor.notion.site/ICP-1a56bd58b00880f085c2ddaa9b153583?pvs=4
<br/>
App:  https://demo.dooor.ai
<br/>


This project provides AMD SEV-SNP attestation capabilities for Akash Network providers, enabling secure deployment verification through hardware-based memory encryption.

## Overview

The system consists of two main components:
- **Webhook**: Automatically injects the attestation sidecar into new pods
- **Attestation Sidecar**: Performs periodic AMD SEV-SNP attestation and exposes verification endpoints

### Architecture
```
Provider Instance
├── Webhook (intercepting new pods)
│   └── Injects Attestation Sidecar
│
└── User Deployments
    ├── User Container
    └── Attestation Sidecar
        ├── Performs AMD SEV verification
        └── Exposes /verify endpoint
```

## Components

### Webhook
Located in `/webhook/`:
- `Dockerfile`: Builds the webhook container
- `webhook.py`: Intercepts new pods and injects the attestation sidecar
- `k8s/webhook.yaml`: Kubernetes configuration for the webhook deployment

The webhook runs at the cluster level and automatically injects the attestation sidecar into every new deployment.

### Attestation Sidecar
Located in `/sidecar/`:
- `Dockerfile`: Builds the attestation container
- `verify-attestation.sh`: Performs periodic AMD SEV-SNP attestation
- `api.py`: Exposes the verification endpoint
- `start.sh`: Initialization script

The sidecar performs attestation every 5 minutes and maintains the current verification status.

# AWS Instance Requirements

To run this attestation system, you need an AWS EC2 instance with AMD SEV-SNP support:

## Compatible Instance Types
- Amazon EC2 M7a instances
- Amazon EC2 R7a instances
- Amazon EC2 C7a instances

## Required Instance Configuration
- Operating System: Ubuntu 22.04 LTS
- Kernel Version: 5.4 or higher with SEV-SNP support
- Instance Size: At least 2 vCPUs and 4GB RAM recommended

## Setting Up AWS Instance
1. Launch a compatible instance type (e.g., m7a.large)
2. Enable AMD SEV-SNP during instance launch
3. Ensure the instance has proper IAM roles for KMS access

# Quick Start Guide
## For AWS Providers
1. Launch a compatible AWS instance (see requirements above)
2. Install Kubernetes/k3s on your instance
3. Deploy the webhook:
```bash
# Clone this repository
git clone https://github.com/yourusername/akash-tee-amd-sev

# Deploy webhook
kubectl apply -f webhook/k8s/webhook.yaml
```

## Installation

1. Build and push Docker images:
```bash
# Build both images
docker-compose build

# Push to Docker Hub
docker push yourdockerhub/sev-webhook:latest
docker push yourdockerhub/sev-attestation:latest
```

2. Deploy the webhook:
```bash
# Create certificates
./scripts/generate-certs.sh

# Deploy webhook
kubectl apply -f webhook/k8s/webhook.yaml
```

## Usage

### For Providers
The webhook automatically injects the attestation sidecar into all new deployments. No additional configuration is needed for individual deployments.

### For Users
Users can verify their deployment's AMD SEV-SNP status through the `/verify` endpoint:
```bash
curl http://your-deployment-url/verify
```

Response example:
```json
{
  "attestation_status": "verified",
  "last_verification": "2025-02-06T20:12:43Z",
  "verification_output": "Reported TCB Boot Loader from certificate matches...",
  "attestation_report": "<base64-encoded-report>",
  "cert_chain": "<base64-encoded-chain>",
  "vlek_certificate": "<base64-encoded-cert>"
}
```

## Security

The attestation process uses AMD's hardware-based security features:
- Memory encryption via AMD SEV-SNP
- Hardware-signed attestation reports
- Verification against AMD's Key Distribution Service (KDS)

Users can independently verify the attestation by:
1. Decoding the base64 attestation report
2. Verifying signatures using AMD's public certificates
3. Confirming hardware measurements

## Technical Details

### Attestation Flow
1. Sidecar generates attestation report using `snpguest`
2. Report is signed by AMD hardware (VCEK)
3. Verification performed against AMD's KDS
4. Results exposed via `/verify` endpoint

## License

This project is licensed under the MIT License - see the LICENSE file for details.
