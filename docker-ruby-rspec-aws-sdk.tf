resource "github_repository" "docker-ruby-rspec-aws-sdk" {
  name        = "docker-ruby-rspec-aws-sdk"
  description = "Official Ruby container with rspec and aws-sdk installed"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-ruby-rspec-aws-sdk-dataworks" {
  repository = "${github_repository.docker-ruby-rspec-aws-sdk.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-ruby-rspec-aws-sdk-master" {
  branch         = "${github_repository.docker-ruby-rspec-aws-sdk.default_branch}"
  repository     = "${github_repository.docker-ruby-rspec-aws-sdk.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
