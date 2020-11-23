resource "github_repository" "dataworks_audit_data_ingest" {
  name        = "dataworks-audit-data-ingest"
  description = "Ingest encrypted UC Kafka audit data into S3"
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "dataworks_audit_data_ingest_dataworks" {
  repository = github_repository.dataworks_audit_data_ingest.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_audit_data_ingest_master" {
  branch         = github_repository.dataworks_audit_data_ingest.default_branch
  repository     = github_repository.dataworks_audit_data_ingest.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_audit_data_ingest" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_audit_data_ingest.name
}

resource "null_resource" "dataworks_audit_data_ingest" {
  triggers = {
    repo = github_repository.dataworks_audit_data_ingest.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_audit_data_ingest.name} '${github_repository.dataworks_audit_data_ingest.description}' ${github_repository.dataworks_audit_data_ingest.template.0.repository}"
  }
}
