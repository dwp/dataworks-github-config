resource "github_repository" "aws-concourse" {
  name        = "aws-concourse"
  description = "An AWS based Concourse platform"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-concourse-dataworks" {
  repository = github_repository.aws-concourse.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws-concourse-master" {
  branch         = github_repository.aws-concourse.default_branch
  repository     = github_repository.aws-concourse.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws-concourse" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws-concourse.name
}

resource "github_actions_secret" "aws_concourse_access_key_id" {
  repository      = github_repository.aws-concourse.name
  secret_name     = "ACTIONS_ACCESS_KEY_ID"
  plaintext_value = var.gha_aws_concourse.access_key_id
}

resource "github_actions_secret" "aws_concourse_secret_access_key" {
  repository      = github_repository.aws-concourse.name
  secret_name     = "ACTIONS_SECRET_ACCESS_KEY"
  plaintext_value = var.gha_aws_concourse.secret_access_key
}

resource "github_actions_secret" "aws_role_mgmt_dev" {
  repository      = github_repository.aws-concourse.name
  secret_name     = "AWS_GHA_ROLE_MGMT_DEV"
  plaintext_value = "arn:aws:iam::${local.account["management-dev"]}:role/gha_aws_concourse"
}

resource "github_actions_secret" "aws_role_mgmt" {
  repository      = github_repository.aws-concourse.name
  secret_name     = "AWS_GHA_ROLE_MGMT"
  plaintext_value = "arn:aws:iam::${local.account["management"]}:role/gha_aws_concourse"
}

resource "github_actions_secret" "terraform_version" {
  repository      = github_repository.aws-concourse.name
  secret_name     = "TERRAFORM_VERSION"
  plaintext_value = var.terraform_12_version
}
