# module "eks_managed_node_group" {
#   source = "./modules/eks-managed-node-group"

#   for_each = { for k, v in var.eks_managed_node_groups : k => v if var.create }

#   create = try(each.value.create, true)

#   cluster_name              = aws_eks_cluster.this[0].name
#   cluster_version           = try(each.value.cluster_version, var.eks_managed_node_group_defaults.cluster_version, aws_eks_cluster.this[0].version)
#   cluster_security_group_id = local.cluster_security_group_id
#   cluster_ip_family         = var.cluster_ip_family

#   # EKS Managed Node Group
#   name            = try(each.value.name, each.key)
#   use_name_prefix = try(each.value.use_name_prefix, var.eks_managed_node_group_defaults.use_name_prefix, true)

#   subnet_ids = try(each.value.subnet_ids, var.eks_managed_node_group_defaults.subnet_ids, var.subnet_ids)

#   min_size     = try(each.value.min_size, var.eks_managed_node_group_defaults.min_size, 1)
#   max_size     = try(each.value.max_size, var.eks_managed_node_group_defaults.max_size, 3)
#   desired_size = try(each.value.desired_size, var.eks_managed_node_group_defaults.desired_size, 1)

#   ami_id              = try(each.value.ami_id, var.eks_managed_node_group_defaults.ami_id, "")
#   ami_type            = try(each.value.ami_type, var.eks_managed_node_group_defaults.ami_type, null)
#   ami_release_version = try(each.value.ami_release_version, var.eks_managed_node_group_defaults.ami_release_version, null)

#   capacity_type        = try(each.value.capacity_type, var.eks_managed_node_group_defaults.capacity_type, null)
#   disk_size            = try(each.value.disk_size, var.eks_managed_node_group_defaults.disk_size, null)
#   force_update_version = try(each.value.force_update_version, var.eks_managed_node_group_defaults.force_update_version, null)
#   instance_types       = try(each.value.instance_types, var.eks_managed_node_group_defaults.instance_types, null)
#   labels               = try(each.value.labels, var.eks_managed_node_group_defaults.labels, null)

#   remote_access = try(each.value.remote_access, var.eks_managed_node_group_defaults.remote_access, {})
#   taints        = try(each.value.taints, var.eks_managed_node_group_defaults.taints, {})
#   update_config = try(each.value.update_config, var.eks_managed_node_group_defaults.update_config, {})
#   timeouts      = try(each.value.timeouts, var.eks_managed_node_group_defaults.timeouts, {})

#   # User data
#   platform                   = try(each.value.platform, var.eks_managed_node_group_defaults.platform, "linux")
#   cluster_endpoint           = try(aws_eks_cluster.this[0].endpoint, "")
#   cluster_auth_base64        = try(aws_eks_cluster.this[0].certificate_authority[0].data, "")
#   cluster_service_ipv4_cidr  = var.cluster_service_ipv4_cidr
#   enable_bootstrap_user_data = try(each.value.enable_bootstrap_user_data, var.eks_managed_node_group_defaults.enable_bootstrap_user_data, false)
#   pre_bootstrap_user_data    = try(each.value.pre_bootstrap_user_data, var.eks_managed_node_group_defaults.pre_bootstrap_user_data, "")
#   post_bootstrap_user_data   = try(each.value.post_bootstrap_user_data, var.eks_managed_node_group_defaults.post_bootstrap_user_data, "")
#   bootstrap_extra_args       = try(each.value.bootstrap_extra_args, var.eks_managed_node_group_defaults.bootstrap_extra_args, "")
#   user_data_template_path    = try(each.value.user_data_template_path, var.eks_managed_node_group_defaults.user_data_template_path, "")

#   # Launch Template
#   create_launch_template          = try(each.value.create_launch_template, var.eks_managed_node_group_defaults.create_launch_template, true)
#   launch_template_name            = try(each.value.launch_template_name, var.eks_managed_node_group_defaults.launch_template_name, each.key)
#   launch_template_use_name_prefix = try(each.value.launch_template_use_name_prefix, var.eks_managed_node_group_defaults.launch_template_use_name_prefix, true)
#   launch_template_version         = try(each.value.launch_template_version, var.eks_managed_node_group_defaults.launch_template_version, null)
#   launch_template_description     = try(each.value.launch_template_description, var.eks_managed_node_group_defaults.launch_template_description, "Custom launch template for ${try(each.value.name, each.key)} EKS managed node group")
#   launch_template_tags            = try(each.value.launch_template_tags, var.eks_managed_node_group_defaults.launch_template_tags, {})

#   ebs_optimized                          = try(each.value.ebs_optimized, var.eks_managed_node_group_defaults.ebs_optimized, null)
#   key_name                               = try(each.value.key_name, var.eks_managed_node_group_defaults.key_name, null)
#   launch_template_default_version        = try(each.value.launch_template_default_version, var.eks_managed_node_group_defaults.launch_template_default_version, null)
#   update_launch_template_default_version = try(each.value.update_launch_template_default_version, var.eks_managed_node_group_defaults.update_launch_template_default_version, true)
#   disable_api_termination                = try(each.value.disable_api_termination, var.eks_managed_node_group_defaults.disable_api_termination, null)
#   kernel_id                              = try(each.value.kernel_id, var.eks_managed_node_group_defaults.kernel_id, null)
#   ram_disk_id                            = try(each.value.ram_disk_id, var.eks_managed_node_group_defaults.ram_disk_id, null)

#   block_device_mappings              = try(each.value.block_device_mappings, var.eks_managed_node_group_defaults.block_device_mappings, {})
#   capacity_reservation_specification = try(each.value.capacity_reservation_specification, var.eks_managed_node_group_defaults.capacity_reservation_specification, null)
#   cpu_options                        = try(each.value.cpu_options, var.eks_managed_node_group_defaults.cpu_options, null)
#   credit_specification               = try(each.value.credit_specification, var.eks_managed_node_group_defaults.credit_specification, null)
#   elastic_gpu_specifications         = try(each.value.elastic_gpu_specifications, var.eks_managed_node_group_defaults.elastic_gpu_specifications, null)
#   elastic_inference_accelerator      = try(each.value.elastic_inference_accelerator, var.eks_managed_node_group_defaults.elastic_inference_accelerator, null)
#   enclave_options                    = try(each.value.enclave_options, var.eks_managed_node_group_defaults.enclave_options, null)
#   instance_market_options            = try(each.value.instance_market_options, var.eks_managed_node_group_defaults.instance_market_options, null)
#   license_specifications             = try(each.value.license_specifications, var.eks_managed_node_group_defaults.license_specifications, null)
#   metadata_options                   = try(each.value.metadata_options, var.eks_managed_node_group_defaults.metadata_options, local.metadata_options)
#   enable_monitoring                  = try(each.value.enable_monitoring, var.eks_managed_node_group_defaults.enable_monitoring, true)
#   network_interfaces                 = try(each.value.network_interfaces, var.eks_managed_node_group_defaults.network_interfaces, [])
#   placement                          = try(each.value.placement, var.eks_managed_node_group_defaults.placement, null)

#   # IAM role
#   create_iam_role               = try(each.value.create_iam_role, var.eks_managed_node_group_defaults.create_iam_role, true)
#   iam_role_arn                  = try(each.value.iam_role_arn, var.eks_managed_node_group_defaults.iam_role_arn, null)
#   iam_role_name                 = try(each.value.iam_role_name, var.eks_managed_node_group_defaults.iam_role_name, null)
#   iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, var.eks_managed_node_group_defaults.iam_role_use_name_prefix, true)
#   iam_role_path                 = try(each.value.iam_role_path, var.eks_managed_node_group_defaults.iam_role_path, null)
#   iam_role_description          = try(each.value.iam_role_description, var.eks_managed_node_group_defaults.iam_role_description, "EKS managed node group IAM role")
#   iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, var.eks_managed_node_group_defaults.iam_role_permissions_boundary, null)
#   iam_role_tags                 = try(each.value.iam_role_tags, var.eks_managed_node_group_defaults.iam_role_tags, {})
#   iam_role_attach_cni_policy    = try(each.value.iam_role_attach_cni_policy, var.eks_managed_node_group_defaults.iam_role_attach_cni_policy, true)
#   iam_role_additional_policies  = try(each.value.iam_role_additional_policies, var.eks_managed_node_group_defaults.iam_role_additional_policies, [])

#   # Security group
#   # vpc_security_group_ids            = [try(each.value.vpc_security_group_ids, var.eks_managed_node_group_defaults.vpc_security_group_ids, true)]
#   vpc_security_group_ids            = [aws_security_group.node[0].id, aws_security_group.cluster[0].id]
#   cluster_primary_security_group_id = try(each.value.attach_cluster_primary_security_group, var.eks_managed_node_group_defaults.attach_cluster_primary_security_group, false) ? aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id : null
#   create_security_group             = try(each.value.create_security_group, var.eks_managed_node_group_defaults.create_security_group, true)
#   security_group_name               = try(each.value.security_group_name, var.eks_managed_node_group_defaults.security_group_name, null)
#   security_group_use_name_prefix    = try(each.value.security_group_use_name_prefix, var.eks_managed_node_group_defaults.security_group_use_name_prefix, true)
#   security_group_description        = try(each.value.security_group_description, var.eks_managed_node_group_defaults.security_group_description, "EKS managed node group security group")
#   vpc_id                            = try(each.value.vpc_id, var.eks_managed_node_group_defaults.vpc_id, var.vpc_id)
#   security_group_rules              = try(each.value.security_group_rules, var.eks_managed_node_group_defaults.security_group_rules, {})
#   security_group_tags               = try(each.value.security_group_tags, var.eks_managed_node_group_defaults.security_group_tags, {})

#   tags = merge(var.tags, try(each.value.tags, var.eks_managed_node_group_defaults.tags, {}))
# }