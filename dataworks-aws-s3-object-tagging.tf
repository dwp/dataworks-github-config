locals {
  dataworks_aws_s3_object_tagger_pipeline_name = "dataworks-aws-s3-object-tagger"
}

resource "github_repository" "dataworks_aws_s3_object_tagger" {
  name             = "dataworks-aws-s3-object-tagger"
  description      = "S3 Object tagger application infrastructure"
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

resource "github_team_repository" "dataworks_aws_s3_object_tagger_dataworks" {
  repository = github_repository.dataworks_aws_s3_object_tagger.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_aws_s3_object_tagger_master" {
  branch         = github_repository.dataworks_aws_s3_object_tagger.default_branch
  repository     = github_repository.dataworks_aws_s3_object_tagger.name
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

resource "github_issue_label" "dataworks_aws_s3_object_tagger" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_aws_s3_object_tagger.name
}

resource "null_resource" "dataworks_aws_s3_object_tagger" {
  triggers = {
    repo = github_repository.dataworks_aws_s3_object_tagger.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_aws_s3_object_tagger.name} '${github_repository.dataworks_aws_s3_object_tagger.description}' ${github_repository.dataworks_aws_s3_object_tagger.template.0.repository}"
  }
}

resource "github_repository_webhook" "dataworks_aws_s3_object_tagger" {
  repository = github_repository.dataworks_aws_s3_object_tagger.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_aws_s3_object_tagger_pipeline_name}/resources/${github_repository.dataworks_aws_s3_object_tagger.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_aws_s3_object_tagger_pr" {
  repository = github_repository.dataworks_aws_s3_object_tagger.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_aws_s3_object_tagger_pipeline_name}/resources/${github_repository.dataworks_aws_s3_object_tagger.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
