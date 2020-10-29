resource "github_repository" "k2hb-reconciliation-trimmer" {
  name             = "dataworks-aws-k2hb-reconciliation-trimmer"
  description      = "Terraform infrastructure repo for K2HB Reconciliation Trimmer"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "k2hb-reconciliation-trimmer_dataworks" {
  repository = github_repository.k2hb-reconciliation-trimmer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "k2hb-reconciliation-trimmer_master" {
  branch         = github_repository.k2hb-reconciliation-trimmer.default_branch
  repository     = github_repository.k2hb-reconciliation-trimmer.name
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

resource "null_resource" "k2hb-reconciliation-trimmer" {
  triggers = {
    repo = github_repository.k2hb-reconciliation-trimmer.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.k2hb-reconciliation-trimmer.name} '${github_repository.k2hb-reconciliation-trimmer.description}' ${github_repository.k2hb-reconciliation-trimmer.template.0.repository}"
  }
}

resource "github_repository_webhook" "k2hb-reconciliation-trimmer" {
  repository = github_repository.k2hb-reconciliation-trimmer.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.k2hb-reconciliation-trimmer.name}/resources/${github_repository.k2hb-reconciliation-trimmer.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "k2hb-reconciliation-trimmer_pr" {
  repository = github_repository.k2hb-reconciliation-trimmer.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.k2hb-reconciliation-trimmer.name}/resources/${github_repository.k2hb-reconciliation-trimmer.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
