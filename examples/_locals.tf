locals {
  name                    = "ex-${replace(basename(path.cwd), "_", "-")}"
  aws_account_number      = local.enabled ? coalesce(data.aws_caller_identity.current.account_id) : ""
  aws_iam_policy_document = try(var.aws_iam_policy_document[0], tostring(var.aws_iam_policy_document), "{}")
  enabled                 = "true"
  eks_cluster_oidc_issuer = module.eks.cluster_oidc_issuer_url #replace(var.eks_cluster_oidc_issuer_url, "https://", "")
  cluster_version         = "1.22"
  region                  = data.aws_region.current.name
  service_account_long_id = format("%v@%v", coalesce(var.service_account_name, "all"), coalesce(var.service_account_namespace, "all"))
  service_account_id      = trimsuffix(local.service_account_long_id, format("@%v", var.service_account_name))
  iam_role_policy_prefix  = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  iam_policy_enabled      = local.enabled
  tags                    = var.tags
}