resource "github_repository" "ami-builder-configs" {
  name        = "ami-builder-configs"
  description = "Configuration files for building various AMIs using ami-builder"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true
}

resource "github_team_repository" "ami-builder-configs-dataworks" {
  repository = "${github_repository.ami-builder-configs.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "ami-builder-configs-master" {
  branch         = "${github_repository.ami-builder-configs.default_branch}"
  repository     = "${github_repository.ami-builder-configs.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
