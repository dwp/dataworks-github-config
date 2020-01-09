resource "github_repository" "snapshot-sender" {
  name        = "snapshot-sender"
  description = "Decrypts and delivers mongo exports created by hbase-to-mongo-export"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "snapshot-sender-dataworks" {
  repository = "${github_repository.snapshot-sender.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "mongo-export-delivery-master" {
  branch         = "${github_repository.snapshot-sender.default_branch}"
  repository     = "${github_repository.snapshot-sender.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
