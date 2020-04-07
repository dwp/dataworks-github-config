resource "github_repository" "dataworks_hardened_images" {
  name        = "dataworks-hardened-images"
  description = "Dataworks specific container images which remove vulnerabilities from their base."
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_hardened_images" {
  repository = "${github_repository.dataworks_hardened_images.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_hardened_images_master" {
  branch         = "${github_repository.dataworks_hardened_images.default_branch}"
  repository     = "${github_repository.dataworks_hardened_images.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}