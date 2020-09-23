resource "github_repository" "hbase_table_provisioner" {
  name             = "hbase-table-provisioner"
  description      = "hbase_table_provisioner"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
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
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "hbase_table_provisioner" {
  triggers = {
    repo = github_repository.hbase_table_provisioner.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.hbase_table_provisioner.name} '${github_repository.hbase_table_provisioner.description}' ${github_repository.hbase_table_provisioner.template.0.repository}"
  }
}
