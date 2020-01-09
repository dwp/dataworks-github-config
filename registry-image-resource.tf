resource "github_repository" "registry-image-resource" {
  name        = "registry-image-resource"
  description = "a resource for images in a Docker registry"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "registry-image-resource-dataworks" {
  repository = "${github_repository.registry-image-resource.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "registry-image-resource-master" {
  branch         = "${github_repository.registry-image-resource.default_branch}"
  repository     = "${github_repository.registry-image-resource.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
