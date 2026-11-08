# Real Config history in the log-archive account (replaces the empty config/ stub).

resource "aws_iam_role" "config" {
  provider = aws.log_archive

  name = "${var.name_prefix}-config-recorder"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "config" {
  provider = aws.log_archive

  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "log_archive" {
  provider = aws.log_archive

  name     = "${var.name_prefix}-log-archive"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_iam_role_policy_attachment.config]
}

resource "aws_config_delivery_channel" "log_archive" {
  provider = aws.log_archive

  name           = "${var.name_prefix}-log-archive"
  s3_bucket_name = aws_s3_bucket.trail.id
  s3_key_prefix  = "config"

  depends_on = [
    aws_config_configuration_recorder.log_archive,
    aws_s3_bucket_policy.trail,
  ]
}

resource "aws_config_configuration_recorder_status" "log_archive" {
  provider = aws.log_archive

  name       = aws_config_configuration_recorder.log_archive.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.log_archive]
}
