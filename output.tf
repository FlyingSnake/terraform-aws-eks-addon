
output "eks_cluster_name" {
  value = data.aws_eks_cluster.eks_cluster.name
}
output "eks_oidc_id" {
  value = local.oidc_id
}
output "eks_addons_installed" {
  value = [for addon, enabled in var.eks_addons : addon if enabled]
}

output "amazon_cloudwatch_observability_role" {
  value = length(aws_iam_role.amazon_cloudwatch_observability) > 0 ? aws_iam_role.amazon_cloudwatch_observability[0].arn : null
}
output "aws_distro_for_opentelemetry_role" {
  value = length(aws_iam_role.aws_distro_for_opentelemetry) > 0 ? aws_iam_role.aws_distro_for_opentelemetry[0].arn : null
}
output "aws_load_balancer_controller_role" {
  value = length(aws_iam_role.aws_load_balancer_controller) > 0 ? aws_iam_role.aws_load_balancer_controller[0].arn : null
}
output "aws_mountpoint_s3_csi_driver_role" {
  value = length(aws_iam_role.aws_mountpoint_s3_csi_driver) > 0 ? aws_iam_role.aws_mountpoint_s3_csi_driver[0].arn : null
}
output "aws_ebs_csi_driver_role" {
  value = length(aws_iam_role.aws_ebs_csi_driver) > 0 ? aws_iam_role.aws_ebs_csi_driver[0].arn : null
}
output "aws_efs_csi_driver_role" {
  value = length(aws_iam_role.aws_efs_csi_driver) > 0 ? aws_iam_role.aws_efs_csi_driver[0].arn : null
}
output "snapshot_controller_role" {
  value = length(aws_iam_role.snapshot_controller) > 0 ? aws_iam_role.snapshot_controller[0].arn : null
}
