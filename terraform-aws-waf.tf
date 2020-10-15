resource "github_repository" "terraform_aws_waf" {
  name             = "terraform-aws-waf"
  description      = "A Terraform module to create an AWS WAF with consistent features"
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

resource "github_team_repository" "terraform_aws_waf" {
  repository = github_repository.terraform_aws_waf.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "example_master" {
  branch         = github_repository.terraform_aws_waf.default_branch
  repository     = github_repository.terraform_aws_waf.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "terraform_aws_waf" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.terraform_aws_waf.name
}

resource "null_resource" "terraform_aws_waf" {
  triggers = {
    repo = github_repository.terraform_aws_waf.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.terraform_aws_waf.name} '${github_repository.terraform_aws_waf.description}' ${github_repository.terraform_aws_waf.template.0.repository}"
  }
}
