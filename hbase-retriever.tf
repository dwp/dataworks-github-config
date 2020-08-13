resource "github_repository" "hbase-retriever" {
  name        = "hbase-retriever"
  description = "Retrieves records from HBase"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "hbase-retriever-dataworks" {
  repository = github_repository.hbase-retriever.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "hbase-retriever-master" {
  branch         = github_repository.hbase-retriever.default_branch
  repository     = github_repository.hbase-retriever.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

