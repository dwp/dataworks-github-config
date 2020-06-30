resource "github_repository" "dataworks_pdm" {
  name             = "dataworks-pdm"
  description      = "This repo holds the Physical Data Model (PDM) code and tests"
  auto_init        = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "dataworks_pdm_dataworks" {
  repository = "${github_repository.dataworks_pdm.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_pdm_master" {
  branch         = "${github_repository.dataworks_pdm.default_branch}"
  repository     = "${github_repository.dataworks_pdm.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "dataworks_pdm" {
  triggers = {
    repo = "${github_repository.dataworks_pdm.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_pdm.name} '${github_repository.dataworks_pdm.description}' ${github_repository.dataworks_pdm.template.0.repository}"
  }
}
