resource "github_repository" "packer-egress-test" {
  name        = "packer-egress-test"
  description = "Lambda to test the internet egress endpoints required by Packer"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "packer-egress-test-dataworks" {
  repository = "${github_repository.packer-egress-test.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "packer-egress-test-master" {
  branch         = "${github_repository.packer-egress-test.default_branch}"
  repository     = "${github_repository.packer-egress-test.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
