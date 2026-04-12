# k3s-cluster module

deploys a k3s cluster on EC2 instances. one server node, two agents by default.

disables traefik and servicelb because i prefer to manage ingress separately.
uses flannel vxlan for networking because it just works.

## usage

```hcl
module "k3s" {
  source     = "../../modules/k3s-cluster"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  ssh_key_name = "my-key"
}
```

## notes

- server nodes get `--cluster-init` for etcd
- agent join token is the cluster name (change this in production, obviously)
- 50GB gp3 root volumes — enough for images and logs
