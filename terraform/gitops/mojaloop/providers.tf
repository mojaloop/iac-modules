terraform { 
  
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 16.0"
    }
    vault = "~> 3.16"
  }
}