resource "github_repository" "dataworks_development_tools" {
  name             = "dataworks-development-tools"
  description      = "Infrastructure for development tools"
  auto_init        = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "dataworks_development_tools_dataworks" {
  repository = "${github_repository.dataworks_development_tools.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_development_tools_master" {
  branch         = "${github_repository.dataworks_development_tools.default_branch}"
  repository     = "${github_repository.dataworks_development_tools.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "dataworks_development_tools" {
  triggers = {
    repo = "${github_repository.dataworks_development_tools.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_development_tools.name} '${github_repository.dataworks_development_tools.description}' ${github_repository.dataworks_development_tools.template.0.repository}"
  }
}
