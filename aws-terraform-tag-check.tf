resource "github_repository" "aws_terraform_tag_check" {
  name             = "aws-terraform-tag-check"
  description      = "GitHub action to check that terraform resources are tagged correctly"
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
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "aws_terraform_tag_check_dataworks" {
  repository = github_repository.aws_terraform_tag_check.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_terraform_tag_check_master" {
  branch         = github_repository.aws_terraform_tag_check.default_branch
  repository     = github_repository.aws_terraform_tag_check.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws_terraform_tag_check" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws_terraform_tag_check.name
}

resource "null_resource" "aws_terraform_tag_check" {
  triggers = {
    repo = github_repository.aws_terraform_tag_check.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_terraform_tag_check.name} '${github_repository.aws_terraform_tag_check.description}' ${github_repository.aws_terraform_tag_check.template.0.repository}"
  }
}

resource "github_actions_secret" "aws_terraform_tag_check_dockerhub_password" {
  repository      = github_repository.aws_terraform_tag_check.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "aws_terraform_tag_check_dockerhub_username" {
  repository      = github_repository.aws_terraform_tag_check.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "aws_terraform_tag_check_snyk_token" {
  repository      = github_repository.aws_terraform_tag_check.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
