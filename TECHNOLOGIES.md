# Technologies & Stack

## Complete Technology Stack for Serverless CI/CD Pipeline

This project demonstrates a **hybrid serverless and containerized** architecture using multiple cloud-native technologies.

---

## 1. AWS Services (Cloud Infrastructure)

### AWS Lambda
- **Purpose**: Serverless compute for event-driven functions
- **Use Case**: Handler functions for CI/CD triggers and auto-remediation
- **File**: `src/lambda/handler.py`
- **Features**: 
  - Event-driven execution
  - Auto-scaling
  - Pay-per-invocation pricing

### AWS Step Functions
- **Purpose**: Orchestrate complex workflows
- **Use Case**: Coordinate Lambda executions, branching logic, error handling
- **Benefits**:
  - Visual workflow definition
  - Built-in retry and error handling
  - Distributed transaction management

### AWS CodePipeline
- **Purpose**: Fully managed CI/CD service
- **Stages**: Source → Build → Test → Security Scan → Deploy → Monitor
- **Integration**: GitHub, CodeBuild, Lambda actions

### AWS CodeBuild
- **Purpose**: Managed build service
- **Use Case**: Compile code, run tests, build artifacts

### Amazon EventBridge
- **Purpose**: Event routing and processing
- **Use Case**: Trigger Lambda functions on CloudWatch alarms and custom events

### Amazon CloudWatch
- **Purpose**: Monitoring, logging, and alerting
- **Metrics**: Error rates, latency, cost tracking
- **Alarms**: Auto-trigger rollback on failure

---

## 2. Container Technologies

### Docker
- **Version**: Multi-stage Dockerfile (Python 3.9-slim)
- **Features**:
  - Lightweight image optimization
  - Security: Non-root user, minimal attack surface
  - Health checks configured
  - Layer caching for fast builds
- **Base Image**: `python:3.9-slim` (143 MB)
- **Final Image**: ~300 MB with dependencies

### Docker Compose
- **Purpose**: Local development and testing
- **Services**: App, database, cache (optional)
- **Use Case**: Test containerized application before K8s deployment

---

## 3. Kubernetes (Container Orchestration)

### Kubernetes Manifests Included

#### Namespace (`k8s/namespace.yaml`)
```yaml
kind: Namespace
metadata:
  name: serverless-cicd
```

#### Deployment (`k8s/deployment.yaml`)
- **Replicas**: 3 (for high availability)
- **Strategy**: Rolling update (maxSurge: 1, maxUnavailable: 1)
- **Resource Limits**:
  - Requests: CPU 250m, Memory 256Mi
  - Limits: CPU 500m, Memory 512Mi
- **Health Checks**:
  - Liveness Probe: HTTP GET /health (30s initial delay)
  - Readiness Probe: HTTP GET /ready (5s initial delay)
- **Security**:
  - Non-root user (UID 1000)
  - Read-only file system option
  - Pod Anti-Affinity for node distribution

### Kubernetes Features Used
- **Service Discovery**: ClusterIP service for internal traffic
- **ConfigMaps**: External configuration management
- **RBAC**: Service accounts and role-based access
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA)
- **Networking**: Service-to-Pod networking
- **Storage**: ConfigMap volumes for configuration

---

## 4. CI/CD & Automation

### GitHub Actions
- **Workflow Files**: `.github/workflows/*.yml`
- **Pipelines**:
  - `ci-pipeline.yml`: Unit tests, build validation
  - `security-scan.yml`: Trivy, dependency scanning
  - `deploy.yml`: Lambda/K8s deployment
  - `rollback.yml`: Automated rollback triggers

### Jenkins (Optional)
- Alternative CI/CD platform
- Groovy pipeline support
- Advanced webhook integration

---

## 5. Code Quality & Testing

### Testing Frameworks
- **pytest**: Unit and integration tests
- **pytest-cov**: Code coverage reports (target: >80%)
- **pytest-mock**: Mocking and patching

### Linting & Formatting
- **Black**: Python code formatter (line length: 88)
- **Flake8**: Style guide enforcement (PEP 8)
- **Pylint**: Code analysis and error detection
- **mypy**: Static type checking

### Security Scanning
- **Trivy**: Container image vulnerability scanning
- **Snyk**: Dependency vulnerability detection
- **Bandit**: Python security linter (SAST)

---

## 6. Infrastructure as Code (IaC)

### Terraform
- **Provider**: AWS
- **Modules**: 
  - Lambda function definition
  - IAM roles and policies
  - CloudWatch log groups
  - EventBridge rules
- **State Management**: S3 backend with DynamoDB locking
- **Variables**: Configurable regions, environment names

### CloudFormation (Alternative)
- JSON/YAML template support
- Native AWS integration

---

## 7. Web Framework & APIs

### Flask
- **Version**: 3.0.0
- **Extensions**:
  - Flask-CORS: Cross-origin requests
  - Flask-RESTX: REST API development with Swagger/OpenAPI
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /ready` - Readiness probe
  - `POST /deploy` - Trigger deployment
  - `POST /rollback` - Execute rollback

---

## 8. Data Processing & Storage

### Databases
- **PostgreSQL**: Production database via psycopg2
- **SQLAlchemy**: ORM for database operations

### Data Processing
- **Pandas**: Data manipulation and analysis
- **NumPy**: Numerical computations

---

## 9. Logging & Monitoring

### Logging
- **python-json-logger**: Structured JSON logging
- **Watchtower**: CloudWatch log integration
- **Log Levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL

### Monitoring & Alerting
- **CloudWatch Metrics**: Custom metrics for pipeline stages
- **CloudWatch Alarms**: Threshold-based alerts
- **Dashboards**: Real-time visualization of metrics

---

## 10. Security & Compliance

### Authentication & Authorization
- **PyJWT**: JWT token handling
- **Cryptography**: Encryption and hashing
- **AWS IAM**: Fine-grained access control

### Configuration Management
- **python-dotenv**: Environment variable loading
- **Pydantic**: Data validation and settings

---

## Technology Comparison: Serverless vs. Kubernetes

| Aspect | AWS Lambda | Kubernetes |
|--------|-----------|------------|
| **Startup Time** | Cold start 1-5s | Pod: 1-3s |
| **Scaling** | Auto (milliseconds) | Manual/HPA (10s-1m) |
| **Cost Model** | Pay-per-invocation | Pay-per-node/hour |
| **Complexity** | Low (FaaS) | High (orchestration) |
| **Control** | Limited | Full customization |
| **Stateless** | Yes (recommended) | Both possible |
| **Best For** | Event-driven, sporadic traffic | Continuous, predictable load |

---

## Tech Stack Summary

```
┌─────────────────────────────────────────────────────┐
│         Application Layer                           │
│  Python 3.9 + Flask + Flask-RESTX + SQLAlchemy     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│      Container Layer                                │
│  Docker (Multi-stage) → Kubernetes or ECS          │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│      Orchestration & CI/CD                          │
│  GitHub Actions + AWS CodePipeline + Terraform     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│      Cloud Infrastructure (AWS)                     │
│  Lambda, Step Functions, CodeBuild, EventBridge    │
│  CloudWatch, SNS, S3, IAM                          │
└─────────────────────────────────────────────────────┘
```

---

## Installation & Version Requirements

```bash
# Python
python >= 3.9

# Docker
docker >= 20.10

# Kubernetes (if using K8s deployment)
kubectl >= 1.24

# Terraform (if using IaC)
terraform >= 1.0

# AWS CLI
aws-cli >= 2.0
```

---

## Integration Points

1. **GitHub** → GitHub Actions Workflows
2. **GitHub Actions** → AWS CodePipeline
3. **CodePipeline** → Lambda Functions
4. **Lambda** → Step Functions Orchestration
5. **Step Functions** → CodeBuild (for build jobs)
6. **CodeBuild** → Docker Registry Push
7. **Docker Images** → Kubernetes Cluster (or ECS)
8. **EventBridge** → CloudWatch → Auto-remediation Lambdas
9. **CloudWatch** → SNS → Notifications

---

## Deployment Topology

```
Local Development
  ↓
Git Push to GitHub
  ↓
GitHub Actions Trigger
  ↓
┌─────────────┬──────────────┐
│   AWS Path  │  K8s Path    │
├─────────────┼──────────────┤
│Lambda Deploy│K8s Manifest  │
│CodePipeline │  kubectl     │
│EventBridge  │  apply       │
└─────────────┴──────────────┘
  ↓                ↓
Production      Production
Serverless      Containerized
```

---

**Last Updated**: December 2024
**Maintainer**: DevOps Engineer | Darshan C D
