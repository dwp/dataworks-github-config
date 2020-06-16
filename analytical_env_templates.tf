resource "github_repository" "analytical_env_templates" {
  name             = "analytical-env-templates"
  description      = "Templates for emails being used within the analytical environment"
  auto_init        = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = false
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "analytical_env_templates_dataworks" {
  repository = "${github_repository.analytical_env_templates.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "analytical_env_templates_master" {
  branch         = "${github_repository.analytical_env_templates.default_branch}"
  repository     = "${github_repository.analytical_env_templates.name}"
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

resource "null_resource" "analytical_env_templates" {
  triggers = {
    repo = "${github_repository.analytical_env_templates.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.analytical_env_templates.name} '${github_repository.analytical_env_templates.description}' ${github_repository.analytical_env_templates.template.repository}"
  }
}
