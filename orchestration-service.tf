resource "github_repository" "orchestration-service" {
  name        = "orchestration-service"
  description = "The service orchestrator for providing remote access into the analytical environment"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  auto_init              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "orchestration-service-dataworks" {
  repository = "${github_repository.orchestration-service.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "orchestration-service-master" {
  branch         = "${github_repository.orchestration-service.default_branch}"
  repository     = "${github_repository.orchestration-service.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
