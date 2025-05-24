terraform {
  backend "s3" {
    bucket         = "terraform-state-assign"
    key            = "infra/dev/terraform.tfstate"
    region         = "us-east-1" 
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    skip_s3_checksum            = true
  }
}
