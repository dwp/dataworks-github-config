resource "github_repository" "docker-ansible-git" {
  name        = "docker-ansible-git"
  description = "Docker CentOS image with Ansible and Git. Used in CI pipeline to install required Ansible roles."

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-ansible-git-dataworks" {
  repository = github_repository.docker-ansible-git.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-ansible-git-master" {
  branch         = github_repository.docker-ansible-git.default_branch
  repository     = github_repository.docker-ansible-git.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker-ansible-git" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker-ansible-git.name
}

