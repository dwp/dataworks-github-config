resource "github_repository" "data-key-service" {
  name        = "data-key-service"
  description = "A service to assist with the generating and decrypting of data keys, backed by either AWS KMS or AWS CloudHSM v2"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "data-key-service-dataworks" {
  repository = "${github_repository.data-key-service.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "data-key-service-master" {
  branch         = "${github_repository.data-key-service.default_branch}"
  repository     = "${github_repository.data-key-service.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
