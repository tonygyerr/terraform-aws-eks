resource "aws_iam_role" "service_account" {
  count              = local.enabled ? 1 : 0
  name               = "${var.app_name}-service-role"
  description        = format("Role assumed by EKS ServiceAccount %s", local.service_account_id)
  assume_role_policy = data.aws_iam_policy_document.service_account_assume_role[0].json
  tags               = merge(map("Name", "${var.app_name}-service-role"), merge(var.tags))
}

data "aws_iam_policy_document" "service_account_assume_role" {
  count = local.enabled ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [format("arn:%s:iam::%s:oidc-provider/%s", data.aws_partition.current.partition, local.aws_account_number, local.eks_cluster_oidc_issuer)]
    }

    condition {
      test     = "StringLike"
      values   = [format("system:serviceaccount:%s:%s", coalesce(var.service_account_namespace, "*"), coalesce(var.service_account_name, "*"))]
      variable = format("%s:sub", local.eks_cluster_oidc_issuer)
    }
  }
}

resource "aws_iam_policy" "service_account" {
  count       = local.iam_policy_enabled ? 1 : 0
  name        = "${var.app_name}-service-policy"
  description = format("Grant permissions to EKS ServiceAccount %s", local.service_account_id)
  # policy      = local.aws_iam_policy_document
  policy = <<POLICY
{   
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "eks:ListClusters",
                "eks:DescribeAddonVersions",
                "eks:RegisterCluster",
                "eks:CreateCluster"
            ],
            "Resource": [
                "arn:aws:eks:${local.region}:${local.aws_account_number}:fargateprofile/*/*/*",
                "arn:aws:eks:${local.region}:${local.aws_account_number}:identityproviderconfig/*/*/*/*",
                "arn:aws:eks:${local.region}:${local.aws_account_number}:cluster/*",
                "arn:aws:eks:${local.region}:${local.aws_account_number}:nodegroup/*/*/*",
                "arn:aws:eks:${local.region}:${local.aws_account_number}:addon/*/*/*"
            ],
            "Effect": "Allow"
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "service_account" {
  count      = local.iam_policy_enabled ? 1 : 0
  role       = aws_iam_role.service_account[0].name
  policy_arn = aws_iam_policy.service_account[0].arn
}