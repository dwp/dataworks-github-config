resource "github_repository" "docker_pushgateway" {
  name             = "docker-pushgateway"
  description      = "Repo for the DataWorks Pushgateway Docker image"
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

resource "github_team_repository" "docker_pushgateway_dataworks" {
  repository = "${github_repository.pushgateway.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker_pushgateway_master" {
  branch         = "${github_repository.pushgateway.default_branch}"
  repository     = "${github_repository.pushgateway.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "docker_pushgateway" {
  triggers = {
    repo = "${github_repository.pushgateway.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.pushgateway.name} '${github_repository.pushgateway.description}' ${github_repository.pushgateway.template.0.repository}"
  }
}

resource "github_actions_secret" "docker_pushgateway_dockerhub_password" {
  repository      = "${github_repository.pushgateway.name}"
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = "${var.dockerhub_password}"
}

resource "github_actions_secret" "docker_pushgateway_dockerhub_username" {
  repository      = "${github_repository.pushgateway.name}"
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = "${var.dockerhub_username}"
}

resource "github_actions_secret" "docker_pushgateway_snyk_token" {
  repository      = "${github_repository.pushgateway.name}"
  secret_name     = "SNYK_TOKEN"
  plaintext_value = "${var.snyk_token}"
}
