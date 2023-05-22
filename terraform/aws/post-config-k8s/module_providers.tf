terraform {
  required_version = "~> 1.0"
  
  required_providers {
    aws   = "~> 3"
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 15"
    }
  }
}