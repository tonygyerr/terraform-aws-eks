resource "aws_kms_key" "eks" {
  description             = "KMS Key for ${var.app_name}-eks"
  deletion_window_in_days = 30
  enable_key_rotation     = "true"
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.app_name}-eks-key" #var.kms_alias
  target_key_id = aws_kms_key.eks.key_id
}