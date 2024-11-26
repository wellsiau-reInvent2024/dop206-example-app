# HCP Terraform uses this to assume the role in the target account
identity_token "aws" {
  audience = ["aws.workload.identity"]
}

identity_token "k8s" {
  audience = ["k8s.workload.identity"]
}

deployment "development" {
  inputs = {
    aws_identity_token  = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::956926424811:role/HCPTerraform-Role-StackSet"
    regions             = ["us-west-2"]
    vpc_name            = "vpc-dev"
    vpc_cidr            = "10.0.0.0/16"

    #EKS Cluster
    kubernetes_version = "1.30"
    cluster_name       = "eksdev"
    
    #EKS OIDC
    tfc_kubernetes_audience   = "k8s.workload.identity"
    tfc_hostname              = "https://app.terraform.io"
    tfc_organization_name     = "wellsiau-stacks-demo"
    eks_clusteradmin_arn      = "arn:aws:iam::956926424811:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSPowerUserAccess_88ca65fdfe62607f"
    eks_clusteradmin_username = "Vending6-PowerUser"

    #K8S
    k8s_identity_token  = identity_token.k8s.jwt
    namespace           = "hashibank"

  }
}

deployment "prod" {
  inputs = {
    aws_identity_token  = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::197831068840:role/HCPTerraform-Role-StackSet"
    regions             = ["us-east-2"]
    vpc_name            = "vpc-prod"
    vpc_cidr            = "10.20.0.0/16"

    #EKS Cluster
    kubernetes_version  = "1.30"
    cluster_name        = "eksprod"
    
    #EKS OIDC
    tfc_kubernetes_audience   = "k8s.workload.identity"
    tfc_hostname              = "https://app.terraform.io"
    tfc_organization_name     = "wellsiau-stacks-demo"
    eks_clusteradmin_arn      = "arn:aws:iam::197831068840:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSPowerUserAccess_f087cff6434aca5c"
    eks_clusteradmin_username = "Vending1-PowerUser"

    #K8S
    k8s_identity_token  = identity_token.k8s.jwt
    namespace           = "hashibank"

  }
}

orchestrate "auto_approve" "safe_plans_dev" {
  check {
      # Only auto-approve in the development environment if no resources are being removed
      condition = context.plan.changes.remove == 0 && context.plan.deployment == deployment.development
      reason = "Plan has ${context.plan.changes.remove} resources to be removed."
  }
}