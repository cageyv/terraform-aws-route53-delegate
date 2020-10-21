output "this_role_arn" {
  value = aws_iam_role.this.arn
}

output "this_policy_arn" {
  value = aws_iam_policy.this.arn
}
