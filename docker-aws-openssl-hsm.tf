resource "github_repository" "docker-aws-openssl-hsm" {
  name        = "docker-aws-openssl-hsm"
  description = "Docker alpine image with AWS CLI and OpenSSL, for HSM"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-aws-openssl-hsm-dataworks" {
  repository = "${github_repository.docker-aws-openssl-hsm.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "docker-aws-openssl-hsm-master" {
  branch         = "${github_repository.docker-aws-openssl-hsm.default_branch}"
  repository     = "${github_repository.docker-aws-openssl-hsm.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
