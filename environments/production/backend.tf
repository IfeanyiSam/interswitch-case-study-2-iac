# terraform {
#   backend "s3" {
#     bucket = "switch-terraform-state-bucket"
#     key    = "environments/production/terraform.tfstate"
#     region = "us-east-1"
#     encrypt      = true  
#     use_lockfile = true
#   }
# }