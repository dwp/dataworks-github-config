resource "github_repository" "streaming-data-importer" {
  name        = "streaming-data-importer"
  description = "Simple shovel utility to move messages from an S3 bucket to Hbase with versioning"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "streaming-data-importer"
  }
}

resource "github_team_repository" "streaming-data-importer-dataworks" {
  repository = github_repository.streaming-data-importer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "streaming-data-importer-master" {
  branch         = github_repository.streaming-data-importer.default_branch
  repository     = github_repository.streaming-data-importer.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "streaming-data-importer" {
  triggers = {
    repo = github_repository.streaming-data-importer.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.streaming-data-importer.name} '${github_repository.streaming-data-importer.description}' ${github_repository.streaming-data-importer.template[0].repository}"
  }
}
