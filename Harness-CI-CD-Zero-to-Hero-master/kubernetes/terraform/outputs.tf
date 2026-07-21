output "eks_cluster_name" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "bastion_public_ip" {
  description = "Bastion server public IP (SSH into this)"
  value       = aws_instance.bastion.public_ip
}

output "bastion_ssh_command" {
  description = "Connect to bastion via SSM (no key needed)"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id} --region ${var.aws_region}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "region" {
  description = "AWS Region"
  value       = var.aws_region
}
