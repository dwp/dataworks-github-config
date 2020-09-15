resource "github_repository" "docker_nginx_s3" {
  name        = "docker-nginx-s3"
  description = "Docker container for nginx that retrieves config from S3 location on launch. Container images published to https://hub.docker.com/r/dwpdigital/nginx."
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "docker_nginx_s3_dataworks" {
  repository = github_repository.docker_nginx_s3.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker_nginx_s3_dataworks" {
  branch         = github_repository.docker_nginx_s3.default_branch
  repository     = github_repository.docker_nginx_s3.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "docker_nginx_s3" {
  triggers = {
    repo = github_repository.docker_nginx_s3.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.docker_nginx_s3.name} '${github_repository.docker_nginx_s3.description}' ${github_repository.docker_nginx_s3.template[0].repository}"
  }
}

resource "github_actions_secret" "docker_nginx_s3_dockerhub_password" {
  repository      = github_repository.docker_nginx_s3.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "docker_nginx_s3_dockerhub_username" {
  repository      = github_repository.docker_nginx_s3.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "docker_nginx_s3_snyk_token" {
  repository      = github_repository.docker_nginx_s3.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

