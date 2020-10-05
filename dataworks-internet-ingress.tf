resource "github_repository" "dataworks_internet_ingress" {
  name        = "dataworks-internet-ingress"
  description = "DataWorks AWS Internet Ingress"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "dataworks_internet_ingress_dataworks" {
  repository = github_repository.dataworks_internet_ingress.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_internet_ingress_master" {
  branch         = github_repository.dataworks_internet_ingress.default_branch
  repository     = github_repository.dataworks_internet_ingress.name
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_internet_ingress" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_internet_ingress.name
}

resource "null_resource" "dataworks_internet_ingress" {
  triggers = {
    repo = github_repository.dataworks_internet_ingress.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_internet_ingress.name} '${github_repository.dataworks_internet_ingress.description}' ${github_repository.dataworks_internet_ingress.template[0].repository}"
  }
}

resource "github_repository_webhook" "dataworks_internet_ingress" {
  repository = github_repository.dataworks_internet_ingress.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/internet-ingress/resources/${github_repository.dataworks_internet_ingress.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_internet_ingress_pr" {
  repository = github_repository.dataworks_internet_ingress.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/internet-ingress/resources/${github_repository.dataworks_internet_ingress.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

