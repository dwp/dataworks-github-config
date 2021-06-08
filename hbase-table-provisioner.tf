resource "github_repository" "hbase_table_provisioner" {
  name        = "hbase-table-provisioner"
  description = "hbase_table_provisioner"
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

resource "github_team_repository" "hbase_table_provisioner_dataworks" {
  repository = github_repository.hbase_table_provisioner.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "hbase_table_provisioner_master" {
  branch         = github_repository.hbase_table_provisioner.default_branch
  repository     = github_repository.hbase_table_provisioner.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "hbase_table_provisioner" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.hbase_table_provisioner.name
}

resource "null_resource" "hbase_table_provisioner" {
  triggers = {
    repo = github_repository.hbase_table_provisioner.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.hbase_table_provisioner.name} '${github_repository.hbase_table_provisioner.description}' ${github_repository.hbase_table_provisioner.template.0.repository}"
  }
}

resource "github_actions_secret" "hbase_table_provisioner_dockerhub_password" {
  repository      = github_repository.hbase_table_provisioner.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "hbase_table_provisioner_dockerhub_username" {
  repository      = github_repository.hbase_table_provisioner.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "hbase_table_provisioner_snyk_token" {
  repository      = github_repository.hbase_table_provisioner.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
