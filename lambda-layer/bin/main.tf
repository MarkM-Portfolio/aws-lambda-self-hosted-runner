# module "self_hosted_runner_a" {
#   source   = "git@github.com:SapphireSystems/terraform-aws-ec2-instance?ref=v1.0.1"
#   for_each = local.self_hosted_runner_a

#   name                   = each.key
#   ami                    = each.value.ami
#   instance_type          = each.value.instance_type
#   subnet_id              = each.value.subnet_id
#   vpc_security_group_ids = each.value.vpc_security_group_ids
#   iam_instance_profile   = lookup(each.value, "iam_instance_profile", "")
#   enable_volume_tags     = false
#   root_block_device      = lookup(each.value, "root_block_device", [])
#   tags = merge(
#     each.value.tags,
#     local.tags
#   )
#   user_data = each.value.user_data
# }

# module "self_hosted_runner_b" {
#   source   = "git@github.com:SapphireSystems/terraform-aws-ec2-instance?ref=v1.0.1"
#   for_each = local.self_hosted_runner_b

#   name                   = each.key
#   ami                    = each.value.ami
#   instance_type          = each.value.instance_type
#   subnet_id              = each.value.subnet_id
#   vpc_security_group_ids = each.value.vpc_security_group_ids
#   iam_instance_profile   = lookup(each.value, "iam_instance_profile", "")
#   enable_volume_tags     = false
#   root_block_device      = lookup(each.value, "root_block_device", [])
#   tags = merge(
#     each.value.tags,
#     local.tags
#   )
#   user_data = each.value.user_data
# }

resource "aws_spot_instance_request" "self_hosted_runner_a" {
  for_each = local.self_hosted_runner_a

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.vpc_security_group_ids
  iam_instance_profile   = each.value.iam_instance_profile
  spot_price             = "0.01"

  root_block_device {
    encrypted             = each.value.root_block_device[0].encrypted
    volume_type           = each.value.root_block_device[0].volume_type
    volume_size           = each.value.root_block_device[0].volume_size
    delete_on_termination = each.value.root_block_device[0].delete_on_termination
    tags                  = local.tags
  }

  tags = merge(
    each.value.tags,
    local.tags
  )

  user_data = base64encode(each.value.user_data)
}

resource "aws_spot_instance_request" "self_hosted_runner_b" {
  for_each = local.self_hosted_runner_b

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.vpc_security_group_ids
  iam_instance_profile   = each.value.iam_instance_profile
  spot_price             = "0.01"

  root_block_device {
    encrypted             = each.value.root_block_device[0].encrypted
    volume_type           = each.value.root_block_device[0].volume_type
    volume_size           = each.value.root_block_device[0].volume_size
    delete_on_termination = each.value.root_block_device[0].delete_on_termination
    tags                  = local.tags
  }

  tags = merge(
    each.value.tags,
    local.tags
  )

  user_data = base64encode(each.value.user_data)
}

resource "aws_ssm_parameter" "parameters" {
  for_each  = local.ansible_parameters
  name      = each.key
  type      = each.value.type
  value     = each.value.value
  overwrite = each.value.overwrite
}
