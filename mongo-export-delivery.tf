resource "github_repository" "mongo-export-delivery" {
  name        = "mongo-export-delivery"
  description = "Decrypts and delivers mongo exports created by hbase-to-mongo-export"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "mongo-export-delivery-dataworks" {
  repository = "${github_repository.mongo-export-delivery.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "mongo-export-delivery-master" {
  branch         = "${github_repository.mongo-export-delivery.default_branch}"
  repository     = "${github_repository.mongo-export-delivery.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
