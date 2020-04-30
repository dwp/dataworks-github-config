resource "github_repository" "docker-python-pyspark-pytest" {
  name        = "docker-python-pyspark-pytest"
  description = "Docker python/3.6-alpine image with pyspark and pytest."
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-python-pyspark-pytest-dataworks" {
  repository = "${github_repository.docker-python-pyspark-pytest.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-python-pyspark-pytest-master" {
  branch         = "${github_repository.docker-python-pyspark-pytest.default_branch}"
  repository     = "${github_repository.docker-python-pyspark-pytest.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "docker-python-pyspark-pytest_dockerhub_password" {
  repository       = "${github_repository.docker-python-pyspark-pytest.name}"
  secret_name      = "DOCKERHUB_PASSWORD"
  plaintext_value  = "${var.dockerhub_password}"
}

resource "github_actions_secret" "docker-python-pyspark-pytest_dockerhub_username" {
  repository       = "${github_repository.docker-python-pyspark-pytest.name}"
  secret_name      = "DOCKERHUB_USERNAME"
  plaintext_value  = "${var.dockerhub_username}"
}

resource "github_actions_secret" "docker-python-pyspark-pytest_snyk_token" {
  repository       = "${github_repository.docker-python-pyspark-pytest.name}"
  secret_name      = "SNYK_TOKEN"
  plaintext_value  = "${var.snyk_token}"
