resource "github_repository" "my_test_repo" {
  name        = "my-test-repo"
  description = "Repo for testing automation"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = false
  }

  template {
    owner      = "${var.github_organization}"
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "my_test_repo_dataworks" {
  repository = "${github_repository.my_test_repo.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "my_test_repo_master" {
  branch         = "${github_repository.my_test_repo.default_branch}"
  repository     = "${github_repository.my_test_repo.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "my_test_repo" {
  triggers = {
    repo = "${github_repository.my_test_repo.name}"
  }
  provisioner "local-exec" {
    command = "dataworks-github-config/initial-commit.sh ${github_repository.my_test_repo.name}"
  }
}
