resource "github_repository" "dataworks-aws-ucfs-stub" {
  name             = "dataworks-aws-ucfs-stub"
  description      = "A repo for DataWorks AWS UCFS export server stub"
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
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "dataworks-aws-ucfs-stub_dataworks" {
  repository = github_repository.dataworks-aws-ucfs-stub.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks-aws-ucfs-stub_master" {
  branch         = github_repository.dataworks-aws-ucfs-stub.default_branch
  repository     = github_repository.dataworks-aws-ucfs-stub.name
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

resource "github_issue_label" "dataworks-aws-ucfs-stub" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks-aws-ucfs-stub.name
}

resource "null_resource" "dataworks-aws-ucfs-stub" {
  triggers = {
    repo = github_repository.dataworks-aws-ucfs-stub.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks-aws-ucfs-stub.name} '${github_repository.dataworks-aws-ucfs-stub.description}' ${github_repository.dataworks-aws-ucfs-stub.template.0.repository}"
  }
}

resource "github_repository_webhook" "dataworks-aws-ucfs-stub" {
  repository = github_repository.dataworks-aws-ucfs-stub.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.dataworks-aws-ucfs-stub.name}/resources/${github_repository.dataworks-aws-ucfs-stub.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks-aws-ucfs-stub_pr" {
  repository = github_repository.dataworks-aws-ucfs-stub.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.dataworks-aws-ucfs-stub.name}/resources/${github_repository.dataworks-aws-ucfs-stub.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}