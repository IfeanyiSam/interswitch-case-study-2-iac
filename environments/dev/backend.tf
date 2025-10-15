# terraform {
#   backend "s3" {
#     bucket = "switch-terraform-state-bucket"
#     key    = "environments/dev/terraform.tfstate"
#     encrypt      = true  
#     use_lockfile = true
#     region = "us-east-1"
#   }
# }