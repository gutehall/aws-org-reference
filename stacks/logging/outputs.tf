output "trail_bucket_policy_json" {
  value = module.logging.trail_bucket_policy_json
}

output "trail_bucket_arn" {
  value = module.logging.trail_bucket_arn
}

output "cloudtrail_log_group_name" {
  value = module.logging.cloudtrail_log_group_name
}

output "config_recorder_name" {
  value = module.logging.config_recorder_name
}
