# output "self_hosted_runner_a_private_ip" {
#   description = "The private IP address assigned to the instance."
#   value = {
#     for k, v in module.self_hosted_runner_a : k => v.private_ip
#   }
# }

# output "self_hosted_runner_b_private_ip" {
#   description = "The private IP address assigned to the instance."
#   value = {
#     for k, v in module.self_hosted_runner_b : k => v.private_ip
#   }
# }

output "self_hosted_runner_a_private_ip" {
  description = "The private IP address assigned to the instance."
  value = {
    for k, v in resource.aws_spot_instance_request.self_hosted_runner_a : k => v.private_ip
  }
}

output "self_hosted_runner_b_private_ip" {
  description = "The private IP address assigned to the instance."
  value = {
    for k, v in resource.aws_spot_instance_request.self_hosted_runner_b : k => v.private_ip
  }
}
