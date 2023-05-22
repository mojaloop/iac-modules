terraform {
  required_version = "~> 1.0"
  
  required_providers {
    aws   = "~> 4.67"
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 16.0"
    }
  }
}