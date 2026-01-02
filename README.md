# Terraform: Scalable EC2 Architecture Behind Application Load Balancer

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?style=flat&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=flat&logo=amazon-aws)](https://aws.amazon.com/)
[![Status](https://img.shields.io/badge/Status-Completed-success?style=flat)]()

> **PROJECT 2 — IMPROVED** | Refactored Non-Modular Version

---

## 📋 Overview

This project demonstrates how to provision a **scalable, load-balanced compute layer** on AWS using Terraform, following infrastructure-as-code best practices. The focus of this project is **correctness, clarity, and production-style architecture decisions** rather than application complexity.

The infrastructure provisions multiple EC2 instances distributed across subnets and places them behind an Application Load Balancer. Each instance serves a simple Nginx web page that dynamically identifies the instance, allowing easy validation of load balancing behavior.

This is a **refactored and improved version** of an earlier project, with cleaner logic, better state management, and clearer separation of responsibilities.

---

## 🏗️ What This Project Builds

- ✅ Remote Terraform state stored in **S3** with **DynamoDB state locking**
- ✅ **Application Load Balancer** (public)
- ✅ **Target Group** with health checks
- ✅ Multiple **EC2 instances** created dynamically
- ✅ Even distribution of instances across available subnets
- ✅ **Security groups** enforcing ALB → EC2 traffic flow
- ✅ Instance bootstrapping using **user data** (Nginx auto-install)
- ✅ Outputs exposing **ALB DNS** for validation

---

## 🏛️ Architecture Summary

```
┌─────────────────────────────────────────────────┐
│                  Internet                        │
└────────────────────┬────────────────────────────┘
                     │
         ┌───────────▼──────────┐
         │  Application Load     │
         │      Balancer         │
         │     (Public)          │
         └───────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │    Target Group       │
         │   (Health Checks)     │
         └───────────┬───────────┘
                     │
      ┌──────────────┼──────────────┐
      │              │              │
┌─────▼─────┐  ┌────▼─────┐  ┌────▼─────┐
│ EC2       │  │ EC2      │  │ EC2      │
│ Instance  │  │ Instance │  │ Instance │
│ (Nginx)   │  │ (Nginx)  │  │ (Nginx)  │
└───────────┘  └──────────┘  └──────────┘
  Subnet 1       Subnet 2      Subnet 3
```

### Key Components:
- **AWS Default VPC** (intentionally used for learning simplicity)
- **Application Load Balancer** in public subnets
- **EC2 instances** distributed across subnets
- ALB forwards HTTP traffic to EC2 target group
- EC2 instances respond with instance-specific content

> **Note:** A custom VPC was intentionally avoided in this project to keep the focus on Terraform logic, state handling, and load balancing mechanics.

---

## 🛠️ Tools and Technologies Used

| Technology | Purpose |
|------------|---------|
| ![Terraform](https://img.shields.io/badge/-Terraform-623CE4?style=flat&logo=terraform&logoColor=white) | Infrastructure as Code |
| ![AWS EC2](https://img.shields.io/badge/-EC2-FF9900?style=flat&logo=amazon-aws&logoColor=white) | Compute Instances |
| ![AWS ALB](https://img.shields.io/badge/-ALB-FF9900?style=flat&logo=amazon-aws&logoColor=white) | Load Balancing |
| ![AWS S3](https://img.shields.io/badge/-S3-569A31?style=flat&logo=amazon-s3&logoColor=white) | Remote State Storage |
| ![DynamoDB](https://img.shields.io/badge/-DynamoDB-4053D6?style=flat&logo=amazon-dynamodb&logoColor=white) | State Locking |
| ![Nginx](https://img.shields.io/badge/-Nginx-009639?style=flat&logo=nginx&logoColor=white) | Web Server |
| ![Ubuntu](https://img.shields.io/badge/-Ubuntu_24.04-E95420?style=flat&logo=ubuntu&logoColor=white) | Operating System |

---

## 🎯 Key Terraform Concepts Demonstrated

### 1. **Remote Backend Configuration**
- S3 bucket for state storage
- DynamoDB table for state locking
- Prevents concurrent modifications

### 2. **Data Sources**
- VPC discovery
- Subnet enumeration
- AMI lookup (Ubuntu 24.04 LTS)

### 3. **Dynamic Resource Creation**
- `for_each` with dynamic instance mapping
- `locals` for computed infrastructure logic
- Deterministic resource naming

### 4. **Infrastructure Logic**
- Modulo arithmetic for subnet distribution
- Template-based user data rendering
- Clean variable usage and outputs

### 5. **Dependency Management**
- Implicit Terraform dependencies
- Resource lifecycle behavior
- Target group attachments

---

## 🔄 Instance Distribution Logic

Instances are created dynamically using a `for_each` loop. Subnets are assigned using **modulo arithmetic** to ensure even distribution across all available subnets without hardcoding subnet IDs.

```hcl
# Example logic (simplified)
subnet_id = element(data.aws_subnets.default.ids, index(keys(local.instances), each.key) % length(data.aws_subnets.default.ids))
```

**Benefits:**
- ✅ Avoids fragile infrastructure definitions
- ✅ Demonstrates deterministic placement logic
- ✅ Scales automatically with available subnets

---

## 🚀 Bootstrap and Validation

Each EC2 instance installs **Nginx** during launch using user data and serves a web page that includes its instance name.

### What This Enables:
- ✅ Load balancer health checks
- ✅ Traffic distribution verification
- ✅ Instance lifecycle behavior validation

### Example Output:
```html
<h1>Hello from instance-1</h1>
<p>This instance is managed by Terraform</p>
```

---

## 💾 Remote State Management

Terraform state is stored in:

| Component | Purpose |
|-----------|---------|
| **S3 Bucket** | Durable state storage |
| **DynamoDB Table** | State locking mechanism |

**Why This Matters:**
- Prevents concurrent state corruption
- Reflects real-world team workflows
- Enables collaboration and CI/CD integration

---

## 🧩 Challenges Faced and Solutions

| Challenge | Solution |
|-----------|----------|
| **Managing state consistency** | Implemented remote backend with DynamoDB locking |
| **Dynamic resource creation** | Used `locals` and `for_each` to avoid hardcoded instance counts |
| **Subnet assignment across AZs** | Applied modulo logic instead of manual subnet mapping |
| **Load balancer target registration** | Attached instances dynamically using `for_each` on the instance map |
| **Dependency ordering** | Relied on implicit Terraform dependencies instead of manual sequencing |
| **Instance bootstrapping reliability** | Used template-based user data instead of inline scripts |

---

## 🔒 Security Considerations

### Current Implementation (Intentional for Learning)

| Component | Configuration | Notes |
|-----------|---------------|-------|
| **ALB** | Publicly accessible on HTTP | For demonstration purposes |
| **EC2 Instances** | Accept HTTP only from ALB security group | Proper isolation |
| **SSH Access** | Parameterized for learning/testing | Configurable CIDR ranges |

### Production Recommendations

> ⚠️ **In production environments:**
> - Replace SSH with **AWS Systems Manager Session Manager**
> - Implement **HTTPS** with AWS Certificate Manager (ACM)
> - Use more restrictive **CIDR ranges**
> - Enable **VPC Flow Logs**
> - Implement **WAF rules** on the ALB

---

## 💡 Why This Project Matters

This project demonstrates:

- ✅ **Practical Terraform usage** beyond basic tutorials
- ✅ **Understanding of AWS load balancing** fundamentals
- ✅ **Ability to reason about infrastructure behavior**
- ✅ **Clean and readable infrastructure code**
- ✅ **Awareness of production concerns** even in learning projects

It is designed to reflect how a **junior-to-mid level DevOps engineer** would structure and explain infrastructure code in a professional environment.

---

## 🚀 Getting Started

### Prerequisites

```bash
# Required tools
terraform >= 1.0
aws-cli >= 2.0
```

### AWS Credentials

```bash
# Configure AWS credentials
aws configure
```

### Deployment Steps

```bash
# 1. Clone the repository
git clone <repository-url>
cd <project-directory>

# 2. Initialize Terraform
terraform init

# 3. Review the execution plan
terraform plan

# 4. Apply the configuration
terraform apply

# 5. Access the application
# Use the ALB DNS name from the output
```

### Validation

```bash
# Get the ALB DNS name
terraform output alb_dns_name

# Test the load balancer
curl http://<alb-dns-name>

# Refresh multiple times to see different instances
for i in {1..10}; do curl http://<alb-dns-name>; done
```

### Cleanup

```bash
# Destroy all resources
terraform destroy
```

---

## 📁 Project Structure

```
.
├── main.tf                 # Main infrastructure definitions
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── backend.tf              # Remote state configuration
├── locals.tf               # Local values and computed logic
├── data.tf                 # Data source definitions
├── user-data.sh            # EC2 bootstrap script
└── README.md               # This file
```

---

## 📊 Outputs

After successful deployment, Terraform provides:

| Output | Description |
|--------|-------------|
| `alb_dns_name` | Public DNS name of the Application Load Balancer |
| `instance_ids` | List of EC2 instance IDs |
| `target_group_arn` | ARN of the target group |

---

## 🔮 Next Improvements (Planned)

- [ ] Convert into **reusable Terraform modules**
- [ ] Replace SSH with **AWS SSM Session Manager**
- [ ] Add **Auto Scaling Group** for dynamic scaling
- [ ] Introduce **HTTPS** with AWS Certificate Manager
- [ ] Create a **custom VPC version** with public/private subnets
- [ ] Implement **CloudWatch dashboards** and alarms
- [ ] Add **Terraform Cloud/Enterprise** integration
- [ ] Include **cost estimation** with Infracost

---

## 📝 Project Status

![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-2.0_Refactored-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Non--Modular_by_Design-orange?style=for-the-badge)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](../../issues).

---

## 👤 Author

**Your Name**

- GitHub: [@adilk-khan-723](https://github.com/adil-khan-723)
- LinkedIn: [@adilk3682](https://www.linkedin.com/in/adilk3682)

---

## 🙏 Acknowledgments

- AWS Documentation
- Terraform Documentation
- HashiCorp Learn Tutorials
- DevOps Community

---

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

<div align="center">

**⭐ If you found this project helpful, please consider giving it a star! ⭐**

Made with ❤️ and ☕ by [Adil khan]

</div>
