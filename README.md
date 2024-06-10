# EKS Addons

AWS EKS Addons Initialization Module

## Usage

```hcl
module "eks-addon" {
  source      = "FlyingSnake/eks-addon/aws"

  name_prefix = "TF-"

  tags = {
    Terraform       = "true"
  }

  # Change it to your EKS cluster name.
  eks_cluster_name = "sample-eks-cluster"

  # Set the addon to install to true or false.
  eks_addons = {
    aws-efs-csi-driver              = true
    aws-ebs-csi-driver              = true
    aws-mountpoint-s3-csi-driver    = true
    snapshot-controller             = true
    eks-pod-identity-agent          = true
    amazon-cloudwatch-observability = true
    aws-distro-for-opentelemetry    = true
  }

  helm_addons = {
    aws-load-balancer-controller = true
    cluster-autoscaler           = true
    appmesh-controller           = true
    argocd                       = true
  }

  # Prerequisites for installing aws-distro-for-opentelemetry. If it is already installed, set it to false.
  cert_manager_install = true
  otel_kubernetes_rbac_apply = true
}
```

## Input

| Name                       | Description                                                                                  | Type   |
| -------------------------- | -------------------------------------------------------------------------------------------- | ------ |
| name_prefix                | Pre Name attached to the name of the AWS resource being created                              | string |
| tags                       | Tags to be attached to created AWS resources                                                 | object |
| eks_cluster_name           | EKS cluster name where addon will be installed                                               | string |
| eks_addons                 | EKS Addons to install                                                                        | object |
| eks_addons_versions        | Addons versions of EKS to be installed                                                       | object |
| helm_addons                | Helm Addons to install                                                                       | object |
| cert_manager_install       | Whether cert-manager is installed(Prerequisites for installing aws-distro-for-opentelemetry) | bool   |
| cert_manager_version       | Version of certmanager installed                                                             | string |
| otel_kubernetes_rbac_apply | Whether to apply Kubernetes RBAC to be used in opentelemetry                                 | bool   |
| app_mesh_controller_config | App Mesh Controller (Helm addon) configuration                                               | object |
| argocd                     | ArgoCD (Helm addon) configuration                                                            | object |

## Output

| Name                                 | Description                                                 | Type         |
| ------------------------------------ | ----------------------------------------------------------- | ------------ |
| eks_cluster_name                     | EKS cluster name where addon will be installed              | string       |
| eks_oidc_id                          | ID of OIDC of EKS cluster                                   | string       |
| eks_addons_installed                 | Installed EKS Addon                                         | list(string) |
| aws_load_balancer_controller_role    | ARN of the IAM role used by aws_load_balancer_controller    | string       |
| aws_efs_csi_driver_role              | ARN of the IAM role used by aws_efs_csi_driver              | string       |
| aws_ebs_csi_driver_role              | ARN of the IAM role used by aws_ebs_csi_driver              | string       |
| aws_mountpoint_s3_csi_driver_role    | ARN of the IAM role used by aws_mountpoint_s3_csi_driver    | string       |
| snapshot_controller_role             | ARN of the IAM role used by snapshot_controller             | string       |
| amazon_cloudwatch_observability_role | ARN of the IAM role used by amazon_cloudwatch_observability | string       |
| aws_distro_for_opentelemetry_role    | ARN of the IAM role used by aws_distro_for_opentelemetry    | string       |
| cluster_autoscaler_role              | ARN of the IAM role used by cluster_autoscaler              | string       |
| appmesh_controller_role              | ARN of the IAM role used by appmesh_controller              | string       |
| appmesh_envoy_role                   | ARN of the IAM role used by appmesh_envoy                   | string       |

## Resources

| Name                                          | Type                           |
| --------------------------------------------- | ------------------------------ |
| amazon_cloudwatch_observability               | aws_iam_role                   |
| amazon_cloudwatch_observability               | aws_eks_addon                  |
| aws_distro_for_opentelemetry                  | aws_iam_role                   |
| aws_distro_for_opentelemetry                  | aws_eks_addon                  |
| kubectl_apply_otel_rbac_yaml                  | null_resource                  |
| kubectl_apply_certmanager_yaml                | null_resource                  |
| aws_load_balancer_controller                  | aws_iam_role                   |
| aws_load_balancer_controller                  | aws_iam_policy                 |
| aws_load_balancer_controller_attach           | aws_iam_role_policy_attachment |
| aws_load_balancer_controller                  | helm_release                   |
| kubectl_apply_aws_load_balancer_controller_sa | null_resource                  |
| aws_mountpoint_s3_csi_driver                  | aws_iam_role                   |
| aws_mountpoint_s3_csi_driver                  | aws_eks_addon                  |
| aws_ebs_csi_driver                            | aws_iam_role                   |
| aws_ebs_csi_driver                            | aws_eks_addon                  |
| aws_efs_csi_driver                            | aws_iam_role                   |
| aws_efs_csi_driver                            | aws_eks_addon                  |
| eks_pod_identity_agent                        | aws_eks_addon                  |
| snapshot_controller                           | aws_iam_role                   |
| snapshot_controller                           | aws_eks_addon                  |
| cluster_autoscaler                            | aws_iam_role                   |
| cluster_autoscaler                            | helm_release                   |
| appmesh_controller                            | aws_iam_role                   |
| appmesh_controller                            | aws_iam_policy                 |
| appmesh_controller_attach                     | aws_iam_role_policy_attachment |
| appmesh_envoy                                 | aws_iam_role                   |
| appmesh_envoy                                 | aws_iam_policy                 |
| appmesh_envoy_attach                          | aws_iam_role_policy_attachment |
| appmesh_controller                            | helm_release                   |
| argocd                                        | helm_release                   |
