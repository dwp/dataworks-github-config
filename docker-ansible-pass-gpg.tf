resource "github_repository" "docker-ansible-pass-gpg" {
  name        = "docker-ansible-pass-gpg"
  description = "Docker CentOS image with Ansible, Pass and GPG. Used in CI pipeline to run Ansible playbooks."

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-ansible-pass-gpg-dataworks" {
  repository = "${github_repository.docker-ansible-pass-gpg.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-ansible-pass-gpg-master" {
  branch         = "${github_repository.docker-ansible-pass-gpg.default_branch}"
  repository     = "${github_repository.docker-ansible-pass-gpg.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
