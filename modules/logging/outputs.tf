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
