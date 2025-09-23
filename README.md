# AWS Lambda Self-Hosted Runner Terraform
## Instructions


* Compile Python Script then upload to AWS Lambda (dev-automation) account <eu-west-2>
```sh
compile.sh
```

| AWS Lambda                                                            | ARN     |
| --------------------------------------------------------------- |-------------------|
| [GitHubEvents](https://eu-west-2.console.aws.amazon.com/lambda/home?region=eu-west-2#/functions/GithubEvents?tab=code)                               | `arn:aws:lambda:eu-west-2:264309510997:function:GithubEvents`   |


| Runtime                                                            | Handler     |
| --------------------------------------------------------------- |-------------------|
|  Python 3.12, Amazon Linux 2 (arm64)                             | `github-events.lambda_handler`   |


| Role Name                                                            | URL     |
| --------------------------------------------------------------- |-------------------|
| GithubEvents-role-axtej3pv                              | [IAM Role](https://us-east-1.console.aws.amazon.com/iam/home?region=eu-west-2#/roles/details/GithubEvents-role-axtej3pv?section=permissions)   |

| Layer                                                            | ARN     |
| --------------------------------------------------------------- |-------------------|
| [GitHubEventsLayer](lambda-layer)                            | `arn:aws:lambda:eu-west-2:264309510997:layer:GitHubEventsLayer:4`  |
