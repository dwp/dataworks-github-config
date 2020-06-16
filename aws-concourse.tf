resource "github_repository" "aws-concourse" {
  name        = "aws-concourse"
  description = "An AWS based Concourse platform"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-concourse-dataworks" {
  repository = "${github_repository.aws-concourse.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-concourse-master" {
  branch         = "${github_repository.aws-concourse.default_branch}"
  repository     = "${github_repository.aws-concourse.name}"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/aws-concourse-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
