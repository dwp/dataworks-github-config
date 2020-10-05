resource "github_repository" "docker-ansible-pass-gpg" {
  name        = "docker-ansible-pass-gpg"
  description = "Docker CentOS image with Ansible, Pass and GPG. Used in CI pipeline to run Ansible playbooks."

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-ansible-pass-gpg-dataworks" {
  repository = github_repository.docker-ansible-pass-gpg.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-ansible-pass-gpg-master" {
  branch         = github_repository.docker-ansible-pass-gpg.default_branch
  repository     = github_repository.docker-ansible-pass-gpg.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker-ansible-pass-gpg" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker-ansible-pass-gpg.name
}

