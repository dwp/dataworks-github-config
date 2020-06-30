resource "github_repository" "dataworks_pdm" {
  name                   = "dataworks-pdm"
  description            = "This repo holds the Physical Data Model (PDM) and its tests"
  auto_init              = true
  is_template            = true
  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_pdm_dataworks" {
  repository = "${github_repository.dataworks_pdm.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_pdm_master" {
  branch         = "${github_repository.dataworks_pdm.default_branch}"
  repository     = "${github_repository.dataworks_pdm.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}