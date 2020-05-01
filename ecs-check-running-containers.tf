resource "github_repository" "ecs-check-running-containers" {
  name        = "ecs-check-running-containers"
  description = "Checks if number of running containers matches the desired number"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "ecs-check-running-containers" {
  repository = "${github_repository.ecs-check-running-containers.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "ecs-check-running-containers" {
  branch         = "${github_repository.ecs-check-running-containers.default_branch}"
  repository     = "${github_repository.ecs-check-running-containers.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
