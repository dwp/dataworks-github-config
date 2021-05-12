resource "github_repository" "historic_data_loader" {
  name             = "historic-data-loader"
  description      = "historic_data_loader"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "historic_data_loader_dataworks" {
  repository = github_repository.historic_data_loader.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "historic_data_loader_master" {
  branch         = github_repository.historic_data_loader.default_branch
  repository     = github_repository.historic_data_loader.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "historic_data_loader" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.historic_data_loader.name
}

resource "null_resource" "historic_data_loader" {
  triggers = {
    repo = github_repository.historic_data_loader.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.historic_data_loader.name} '${github_repository.historic_data_loader.description}' ${github_repository.historic_data_loader.template.0.repository}"
  }
}
