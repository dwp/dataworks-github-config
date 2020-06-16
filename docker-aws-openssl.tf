resource "github_repository" "docker-aws-openssl" {
  name        = "docker-aws-openssl"
  description = "Docker alpine image with AWS CLI and OpenSSL"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-aws-openssl-dataworks" {
  repository = "${github_repository.docker-aws-openssl.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-aws-openssl-master" {
  branch         = "${github_repository.docker-aws-openssl.default_branch}"
  repository     = "${github_repository.docker-aws-openssl.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
