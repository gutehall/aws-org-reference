# Network stack fails closed without a real network account id.

mock_provider "aws" {}

mock_provider "aws" {
  alias = "network"
}

mock_provider "aws" {
  alias = "workload_0"
}

mock_provider "aws" {
  alias = "workload_1"
}

mock_provider "aws" {
  alias = "workload_2"
}

mock_provider "aws" {
  alias = "workload_3"
}

run "rejects_missing_network_account" {
  command         = plan
  expect_failures = [var.network_account_id]

  variables {
    network_account_id     = ""
    log_archive_account_id = "222222222222"
    flow_logs_bucket_arn   = "arn:aws:s3:::example-trail"
    workload_account_ids   = []
    workload_vpcs          = []
  }
}

run "rejects_non_account_id" {
  command         = plan
  expect_failures = [var.network_account_id]

  variables {
    network_account_id     = "not-an-account"
    log_archive_account_id = "222222222222"
    flow_logs_bucket_arn   = "arn:aws:s3:::example-trail"
    workload_account_ids   = []
    workload_vpcs          = []
  }
}
