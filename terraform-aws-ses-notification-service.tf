resource "github_repository" "terraform-aws-ses-notification-service" {
  name        = "terraform-aws-ses-notification-service"
  description = "Terraform module that creates a service to recieve notifications and distrubute emails via AWS SES"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-ses-notification-service-dataworks" {
  repository = "${github_repository.terraform-aws-ses-notification-service.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "terraform-aws-ses-notification-service-master" {
  branch         = "${github_repository.terraform-aws-ses-notification-service.default_branch}"
  repository     = "${github_repository.terraform-aws-ses-notification-service.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}