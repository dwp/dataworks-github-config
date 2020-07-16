resource "github_repository" "cloudwatch_exporter" {
  name             = "cloudwatch-exporter"
  description      = "cloudwatch-exporter"
  auto_init        = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "cloudwatch_exporter_dataworks" {
  repository = "${github_repository.cloudwatch-exporter.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "cloudwatch_exporter_master" {
  branch         = "${github_repository.cloudwatch-exporter.default_branch}"
  repository     = "${github_repository.cloudwatch-exporter.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "cloudwatch_exporter" {
  triggers = {
    repo = "${github_repository.cloudwatch-exporter.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.cloudwatch-exporter.name} '${github_repository.cloudwatch-exporter.description}' ${github_repository.cloudwatch-exporter.template.0.repository}"
  }
}

resource "github_actions_secret" "cloudwatch_exporter_dockerhub_password" {
  repository      = "${github_repository.cloudwatch-exporter.name}"
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = "${var.dockerhub_password}"
}

resource "github_actions_secret" "cloudwatch_exporter_dockerhub_username" {
  repository      = "${github_repository.cloudwatch-exporter.name}"
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = "${var.dockerhub_username}"
}

resource "github_actions_secret" "cloudwatch_exporter_snyk_token" {
  repository      = "${github_repository.cloudwatch-exporter.name}"
  secret_name     = "SNYK_TOKEN"
  plaintext_value = "${var.snyk_token}"
}
