resource "github_repository" "dataworks-common-logging" {
  name        = "dataworks-common-logging"
  description = "Kotlin utility library to be used in Dataworks applications to ensure common logging format."
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-common-logging-dataworks" {
  repository = github_repository.dataworks-common-logging.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks-common-logging-master" {
  branch         = github_repository.dataworks-common-logging.default_branch
  repository     = github_repository.dataworks-common-logging.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

