resource "github_repository" "ami-builder" {
  name        = "ami-builder"
  description = "Build AMIs using a Lambda function"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "ami-builder-dataworks" {
  repository = "${github_repository.ami-builder.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "ami-builder-master" {
  branch         = "${github_repository.ami-builder.default_branch}"
  repository     = "${github_repository.ami-builder.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "ami-builder_github_email" {
  repository      = "${github_repository.ami-builder.name}"
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = "${var.github_email}"
}

resource "github_actions_secret" "ami-builder_github_username" {
  repository      = "${github_repository.ami-builder.name}"
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = "${var.github_username}"
}

resource "github_actions_secret" "ami-builder_github_token" {
  repository      = "${github_repository.ami-builder.name}"
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = "${var.github_token}"
}
