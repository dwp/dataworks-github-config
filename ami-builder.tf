resource "github_repository" "ami-builder" {
  name        = "ami-builder"
  description = "Build AMIs using a Lambda function"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true
}

resource "github_team_repository" "ami-builder-dataworks" {
  repository = "${github_repository.ami-builder.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "ami-builder-master" {
  branch         = "${github_repository.ami-builder.default_branch}"
  repository     = "${github_repository.ami-builder.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
