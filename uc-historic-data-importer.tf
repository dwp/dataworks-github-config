resource "github_repository" "uc-historic-data-importer" {
  name        = "uc-historic-data-importer"
  description = "Import UC mongo backup into hbase."

  allow_merge_commit = false
  auto_init          = true
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "uc-historic-data-importer-dataworks" {
  repository = "${github_repository.uc-historic-data-importer.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "uc-historic-data-importer-master" {
  branch         = "${github_repository.uc-historic-data-importer.default_branch}"
  repository     = "${github_repository.uc-historic-data-importer.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
    contexts = ["ci/circleci: build-image"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
