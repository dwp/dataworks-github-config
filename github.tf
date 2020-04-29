variable github_token {
  type = "string"
}

variable github_organization {
  type = "string"
}

provider "github" {
  token        = "${var.github_token}"
  organization = "${var.github_organization}"
  version      = "~> 2.6.1"
}
