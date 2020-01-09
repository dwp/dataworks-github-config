resource "github_repository" "docker-ansible-git" {
  name        = "docker-ansible-git"
  description = "Docker CentOS image with Ansible and Git. Used in CI pipeline to install required Ansible roles."

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-ansible-git-dataworks" {
  repository = "${github_repository.docker-ansible-git.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-ansible-git-master" {
  branch         = "${github_repository.docker-ansible-git.default_branch}"
  repository     = "${github_repository.docker-ansible-git.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
