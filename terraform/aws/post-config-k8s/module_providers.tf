terraform {
  required_version = "~> 1.0"
  
  required_providers {
    aws   = "~> 3.74"
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 16.0"
    }
  }
}