resource "aws_kms_key" "vault_unseal" {
  description             = "${var.project} Vault auto-unseal"
  deletion_window_in_days = 14
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Root"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "vault_unseal" {
  name          = "alias/${var.project}-vault-unseal"
  target_key_id = aws_kms_key.vault_unseal.key_id
}

# --- IRSA for the Vault ServiceAccount ---
data "aws_iam_policy_document" "vault_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:vault:vault"]
    }
  }
}

resource "aws_iam_role" "vault" {
  name               = "${var.project}-vault"
  assume_role_policy = data.aws_iam_policy_document.vault_assume.json
}

resource "aws_iam_role_policy" "vault_kms" {
  role = aws_iam_role.vault.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      Resource = aws_kms_key.vault_unseal.arn
    }]
  })
}

output "vault_kms_key_id"   { value = aws_kms_key.vault_unseal.key_id }
output "vault_irsa_role_arn"{ value = aws_iam_role.vault.arn }
