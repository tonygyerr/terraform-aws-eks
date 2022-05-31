module "eks" {
  source = "git::https://github.com/tonygyerr/terraform-aws-eks.git"

  profile                         = var.profile
  region                          = var.aws_region
  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # IPV6
  cluster_ip_family = "ipv6"
  create_cni_ipv6_iam_policy = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = aws_iam_role.service_account[0].arn
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  cluster_tags = {
    Name = "${var.app_name}-${var.environment}-cluster"
  }

  vpc_id     = var.vpc_config.vpc_id
  subnet_ids = var.subnet_ids

  manage_aws_auth_configmap = true

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    default_node_group = {
      create_launch_template = false
      launch_template_name   = "${var.app_name}-launch-template"

      disk_size = 50

      remote_access = {
        ec2_ssh_key               = var.key_name #aws_key_pair.this.key_name
        source_security_group_ids = var.vpc_security_group_ids
      }
    }

    bottlerocket_default = {
      create_launch_template = false
      ami_type               = "BOTTLEROCKET_x86_64"
      platform               = "bottlerocket"
    }

    bottlerocket_add = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      bootstrap_extra_args = <<-EOT
      # extra args added
      [settings.kernel]
      lockdown = "integrity"
      EOT
    }

    bottlerocket_custom = {
      ami_id   = data.aws_ami.eks_default_bottlerocket.image_id
      platform = "bottlerocket"
      enable_bootstrap_user_data = true

      bootstrap_extra_args = <<-EOT
      # extra args added
      [settings.kernel]
      lockdown = "integrity"
      [settings.kubernetes.node-labels]
      "label1" = "foo"
      "label2" = "bar"
      [settings.kubernetes.node-taints]
      "dedicated" = "experimental:PreferNoSchedule"
      "special" = "true:NoSchedule"
      EOT
    }

    external_lt = {
      create_launch_template  = false
      launch_template_name    = "${var.app_name}-launch-template" #module.eks.launch_template_name #aws_launch_template.external.name
      launch_template_version = var.launch_template_version
    }

    custom_ami = {
      ami_type = "AL2_ARM_64"
      ami_id = data.aws_ami.eks_default_arm.image_id

      enable_bootstrap_user_data = true

      instance_types = ["t4g.medium"]
    }

    containerd = {
      name = "containerd"

      pre_bootstrap_user_data = <<-EOT
      #!/bin/bash
      set -ex
      cat <<-EOF > /etc/profile.d/bootstrap.sh
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      export KUBELET_EXTRA_ARGS="--max-pods=110"
      EOF
      # Source extra environment variables in bootstrap script
      sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
      EOT
    }

    complete = {
      name            = "complete-eks-mng"
      use_name_prefix = true

      subnet_ids = var.subnet_ids

      min_size     = 1
      max_size     = 7
      desired_size = 1

      ami_id                     = data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"

      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT

      post_bootstrap_user_data = <<-EOT
      echo "release on the kracken!"
      EOT

      capacity_type        = "SPOT"
      force_update_version = true
      instance_types       = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      description = "EKS managed node group launch template"

      ebs_optimized           = true
      vpc_security_group_ids  = [var.vpc_security_group_ids]
      disable_api_termination = false
      enable_monitoring       = true
      # eks_managed_node_group_id = [module.eks_managed_node_group.node_group_id] #var.eks_managed_node_group_id

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = aws_kms_key.eks.arn
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]

      create_security_group          = true
      security_group_name            = "eks-managed-node-group-complete-example"
      security_group_use_name_prefix = false
      security_group_description     = "EKS managed node group complete example security group"
      security_group_rules = {
        phoneOut = {
          description = "Hello CloudFlare"
          protocol    = "udp"
          from_port   = 53
          to_port     = 53
          type        = "egress"
          cidr_blocks = ["1.1.1.1/32"]
        }
        phoneHome = {
          description                   = "Hello cluster"
          protocol                      = "udp"
          from_port                     = 53
          to_port                       = 53
          type                          = "egress"
          source_cluster_security_group = true # bit of reflection lookup
        }
      }
      security_group_tags = {
        Purpose = "Protector of the kubelet"
      }

      tags = {
        ExtraTag = "EKS managed node group complete example"
      }
    }
  }

  tags = local.tags
}