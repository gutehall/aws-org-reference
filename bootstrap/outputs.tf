output "state_bucket_name" {
  description = "S3 bucket for Terraform state in the management account."
  value       = aws_s3_bucket.state.id
}

output "state_lock_table_name" {
  description = "DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.lock.name
}

output "terraform_role_arn" {
  description = "IAM role assumed via GitHub OIDC for later applies. Module CI must not assume this role."
  value       = aws_iam_role.terraform.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN in the management account."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "backend_config_hcl" {
  description = "Suggested backend block for later stacks in this client."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.state.id}"
        key            = "REPLACE_STACK/terraform.tfstate"
        region         = "${var.home_region}"
        dynamodb_table = "${aws_dynamodb_table.lock.name}"
        encrypt        = true
      }
    }
  EOT
}
