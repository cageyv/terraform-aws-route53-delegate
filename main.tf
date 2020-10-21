locals {
  name = var.name == "" ? "route53_delegate_${var.zone_id}" : var.name
}

data "aws_iam_policy_document" "role_external_id" {
  count = var.external_id == "" ? 0 : 1
  statement {
    principals {
      type        = "AWS"
      identifiers = var.principal_arns
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "role" {
  count = var.external_id == "" ? 1 : 0
  statement {
    principals {
      type        = "AWS"
      identifiers = var.principal_arns
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.name
  assume_role_policy = var.external_id == "" ? data.aws_iam_policy_document.role[0].json : data.aws_iam_policy_document.role_external_id[0].json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "hostedzone"
    effect = "Allow"
    actions = [
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]
    resources = [
      "arn:aws:route53:::change/*",
      "arn:aws:route53:::hostedzone/${var.zone_id}",
      "arn:aws:route53:::healthcheck/${var.zone_id}",
    ]
  }
  statement {
    sid    = "route53"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:GetHostedZoneCount",
      "route53:ListHostedZonesByName"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = local.name
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

