resource "awscc_appsync_source_api_association" "awscc_appsync_source_api_association" {
  merged_api_identifier = var.merged_api_identifier
  source_api_association_config = {
    merge_type = var.merge_type
  }
  source_api_identifier = var.source_api_identifier
}

resource "aws_iam_policy" "policy" {
  name = "SourceGraphQL-for-${var.source_api_identifier}-API"
  path = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "appsync:SourceGraphQL"
        ],
        Resource : [
          "arn:aws:appsync:${var.region}:${var.aws_account_id}:apis/${var.source_api_identifier}/types/*/fields/*",
          "arn:aws:appsync:${var.region}:${var.aws_account_id}:apis/${var.source_api_identifier}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = var.merge_api_role_name
  policy_arn = aws_iam_policy.policy.arn
}
