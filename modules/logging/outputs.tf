output "trail_bucket_arn" {
  description = "Organization trail / Config history bucket in the log-archive account."
  value       = aws_s3_bucket.trail.arn
}

output "trail_bucket_name" {
  value = aws_s3_bucket.trail.id
}

output "trail_bucket_policy_json" {
  description = "Bucket policy JSON for tests (must deny DeleteObject except break-glass)."
  value       = local.trail_bucket_policy
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.organization.arn
}

output "cloudtrail_log_group_name" {
  description = "CloudWatch Logs group receiving organization trail events (for break-glass detection)."
  value       = aws_cloudwatch_log_group.trail.name
}

output "cloudtrail_log_group_arn" {
  value = aws_cloudwatch_log_group.trail.arn
}

output "config_recorder_name" {
  value = aws_config_configuration_recorder.log_archive.name
}
