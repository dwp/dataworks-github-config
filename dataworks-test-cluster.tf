locals {
  dataworks_test_cluster_pipeline_name = "dataworks_test_cluster"
}

resource "github_repository" "dataworks_test_cluster" {
  name             = "dataworks-test-cluster"
  description      = "Creating a test repo to test the template"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
    repository = "aws-emr-template-repository"
  }
}

resource "github_team_repository" "dataworks_test_cluster_dataworks" {
  repository = github_repository.dataworks_test_cluster.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_test_cluster_master" {
  branch         = github_repository.dataworks_test_cluster.default_branch
  repository     = github_repository.dataworks_test_cluster.name
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

resource "github_issue_label" "dataworks_test_cluster" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_test_cluster.name
}

resource "null_resource" "dataworks_test_cluster" {
  triggers = {
    repo = github_repository.dataworks_test_cluster.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_test_cluster.name} '${github_repository.dataworks_test_cluster.description}' ${github_repository.dataworks_test_cluster.template.0.repository}"
  }
}

resource "github_repository_webhook" "dataworks_test_cluster" {
  repository = github_repository.dataworks_test_cluster.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_test_cluster_pipeline_name}/resources/${github_repository.dataworks_test_cluster.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_test_cluster_pr" {
  repository = github_repository.dataworks_test_cluster.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_test_cluster_pipeline_name}/resources/${github_repository.dataworks_test_cluster.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
