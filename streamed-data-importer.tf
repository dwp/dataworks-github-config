resource "github_repository" "streaming_data_importer" {
  name        = "streaming-data-importer"
  description = "Simple shovel utility to move messages from S3 to Hbase with versioning"
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "streaming_data_importer_dataworks" {
  repository = github_repository.streaming_data_importer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "streaming_data_importer_master" {
  branch         = github_repository.streaming_data_importer.default_branch
  repository     = github_repository.streaming_data_importer.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "streaming_data_importer" {
  triggers = {
    repo = github_repository.streaming_data_importer.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.streaming_data_importer.name} '${github_repository.streaming_data_importer.description}' ${github_repository.streaming_data_importer.template.0.repository}"
  }
}
