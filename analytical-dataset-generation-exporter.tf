resource "github_repository" "analytical_dataset_generation_exporter" {
  name             = "analytical-dataset-generation-exporter"
  description      = "Custom spark metric exporter for the Analytical Dataset Generator"
  auto_init        = false

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

resource "github_team_repository" "analytical_dataset_generation_exporter_dataworks" {
  repository = "${github_repository.analytical_dataset_generation_exporter.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "analytical_dataset_generation_exporter_master" {
  branch         = "${github_repository.analytical_dataset_generation_exporter.default_branch}"
  repository     = "${github_repository.analytical_dataset_generation_exporter.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "analytical_dataset_generation_exporter" {
  triggers = {
    repo = "${github_repository.analytical_dataset_generation_exporter.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.analytical_dataset_generation_exporter.name} '${github_repository.analytical_dataset_generation_exporter.description}' ${github_repository.analytical_dataset_generation_exporter.template.0.repository}"
  }
}
