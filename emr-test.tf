resource "github_repository" "aws_emr_test" {
  name             = "aws-emr-test"
  description      = "aws_emr_test"
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
    repository = "aws-emr-template-repository"
  }
}

resource "github_team_repository" "aws_emr_test_dataworks" {
  repository = github_repository.aws_emr_test.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_emr_test_master" {
  branch         = github_repository.aws_emr_test.default_branch
  repository     = github_repository.aws_emr_test.name
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

resource "github_issue_label" "aws_emr_test" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws_emr_test.name
}

resource "null_resource" "aws_emr_test" {
  triggers = {
    repo = github_repository.aws_emr_test.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_emr_test.name} '${github_repository.aws_emr_test.description}' ${github_repository.aws_emr_test.template.0.repository}"
  }
}

resource "github_actions_secret" "aws_emr_test_dockerhub_password" {
  repository      = github_repository.aws_emr_test.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "aws_emr_test_dockerhub_username" {
  repository      = github_repository.aws_emr_test.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "aws_emr_test_snyk_token" {
  repository      = github_repository.aws_emr_test.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
