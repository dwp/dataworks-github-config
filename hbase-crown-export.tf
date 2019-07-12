resource "github_repository" "hbase-crown-export" {
  name        = "hbase-crown-export"
  description = ""

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "hbase-crown-export-dataworks" {
  repository = "${github_repository.hbase-crown-export.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "hbase-crown-export-master" {
  branch         = "${github_repository.hbase-crown-export.default_branch}"
  repository     = "${github_repository.hbase-crown-export.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
