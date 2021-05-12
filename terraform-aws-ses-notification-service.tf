resource "github_repository" "terraform-aws-ses-notification-service" {
  name        = "terraform-aws-ses-notification-service"
  description = "Terraform module that creates a service to recieve notifications and distrubute emails via AWS SES"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-ses-notification-service-dataworks" {
  repository = github_repository.terraform-aws-ses-notification-service.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "terraform-aws-ses-notification-service-master" {
  branch         = github_repository.terraform-aws-ses-notification-service.default_branch
  repository     = github_repository.terraform-aws-ses-notification-service.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "terraform-aws-ses-notification-service" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.terraform-aws-ses-notification-service.name
}

