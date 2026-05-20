locals {
  is_irsa = var.oidc_provider_arn != null && var.service_account_name != null
  tags    = merge(var.tags, { ManagedBy = "terraform" })
}

data "aws_iam_policy_document" "assume_role" {
  dynamic "statement" {
    for_each = var.assume_role_principals
    content {
      actions = ["sts:AssumeRole"]
      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
    }
  }

  dynamic "statement" {
    for_each = local.is_irsa ? [1] : []
    content {
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type        = "Federated"
        identifiers = [var.oidc_provider_arn]
      }
      condition {
        test     = "StringEquals"
        variable = "${var.oidc_provider_url}:sub"
        values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
      }
      condition {
        test     = "StringEquals"
        variable = "${var.oidc_provider_url}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies
  name     = each.key
  role     = aws_iam_role.this.id
  policy   = each.value
}
