resource "github_repository" "terraform_aws_wafv2" {
  name             = "terraform-aws-wafv2"
  description      = "A Terraform module to create an AWS WAFV2 with consistent features"
  auto_init        = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "terraform_aws_wafv2_dataworks" {
  repository = "${github_repository.terraform_aws_wafv2.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "terraform_aws_wafv2_master" {
  branch         = "${github_repository.terraform_aws_wafv2.default_branch}"
  repository     = "${github_repository.terraform_aws_wafv2.name}"
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

resource "null_resource" "terraform_aws_wafv2" {
  triggers = {
    repo = "${github_repository.terraform_aws_wafv2.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.terraform_aws_wafv2.name} '${github_repository.terraform_aws_wafv2.description}' ${github_repository.terraform_aws_wafv2.template.0.repository}"
  }
}

resource "github_repository_webhook" "terraform_aws_wafv2" {
  repository = "${github_repository.terraform_aws_wafv2.name}"
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.terraform_aws_wafv2.name}/resources/${github_repository.terraform_aws_wafv2.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "terraform_aws_wafv2_pr" {
  repository = "${github_repository.terraform_aws_wafv2.name}"
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.terraform_aws_wafv2.name}/resources/${github_repository.terraform_aws_wafv2.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
