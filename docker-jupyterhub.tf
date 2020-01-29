resource "github_repository" "docker-jupyterhub" {
  name        = "docker-jupyterhub"
  description = "A JupyterHub container with required extensions and libraries"

  allow_merge_commit = false
  auto_init          = true
  has_issues         = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-jupyterhub-dataworks" {
  repository = "${github_repository.docker-jupyterhub.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-jupyterhub-master" {
  branch         = "${github_repository.docker-jupyterhub.default_branch}"
  repository     = "${github_repository.docker-jupyterhub.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
