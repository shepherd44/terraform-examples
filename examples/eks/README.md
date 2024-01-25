# EKS Example

## prerequisites

- aws cli > v2.7.25
  - https://stackoverflow.com/questions/73744199/unable-to-connect-to-the-server-getting-credentials-decoding-stdout-no-kind

## provider

- aws
- kubernetes

## Resources

- vpc
- eks

## Deploy

```shell
terraform init
terraform plan 
terraform apply
```

# References
- [terraform eks module example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v19.21.0/examples/complete)
