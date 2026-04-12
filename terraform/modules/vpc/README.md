# vpc module

wraps terraform-aws-modules/vpc/aws with sensible defaults for a homelab setup.

single NAT gateway by default because this isn't a bank and i'm not made of money.

## usage

```hcl
module "vpc" {
  source = "../../modules/vpc"
  name   = "homelab"
  cidr   = "10.0.0.0/16"
}
```
