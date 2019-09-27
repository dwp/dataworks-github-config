resource "github_repository" "emr-encryption-materials-provider" {
  name        = "emr-encryption-materials-provider"
  description = "An EMR Security Configuration plugin implementing transparent client-side encryption and decryption between EMR and data persisted in S3 (via EMRFS)"

  allow_merge_commit = false
  auto_init          = true
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "emr-encryption-materials-provider-dataworks" {
  repository = "${github_repository.emr-encryption-materials-provider.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "emr-encryption-materials-provider-master" {
  branch         = "${github_repository.emr-encryption-materials-provider.default_branch}"
  repository     = "${github_repository.emr-encryption-materials-provider.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
