terraform {
  required_version = "~> 1.0"
  
  required_providers {
    aws   = "~> 3.7"
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 15.11"
    }
  }
}