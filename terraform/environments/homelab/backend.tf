# remote state — uncomment and configure for your setup
# for a homelab, s3 backend with dynamodb locking is fine
# or just use local state if you're the only operator

# terraform {
#   backend "s3" {
#     bucket         = "homelab-terraform-state"
#     key            = "homelab/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

# using local state for now
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
