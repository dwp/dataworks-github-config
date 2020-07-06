resource "github_repository" "mysql_query_lambda" {
  name             = "mysql-query-lambda"
  description      = "AWS Lambda to connect to MySQL database, execute query, and return results"
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

resource "github_team_repository" "mysql_query_lambda_dataworks" {
  repository = "${github_repository.mysql_query_lambda.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "mysql_query_lambda_master" {
  branch         = "${github_repository.mysql_query_lambda.default_branch}"
  repository     = "${github_repository.mysql_query_lambda.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "mysql_query_lambda" {
  triggers = {
    repo = "${github_repository.mysql_query_lambda.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.mysql_query_lambda.name} '${github_repository.mysql_query_lambda.description}' ${github_repository.mysql_query_lambda.template.0.repository}"
  }
}

resource "github_actions_secret" "mysql_query_lambda_github_email" {
  repository      = "${github_repository.mysql_query_lambda.name}"
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = "${var.github_email}"
}

resource "github_actions_secret" "mysql_query_lambda_github_username" {
  repository      = "${github_repository.mysql_query_lambda.name}"
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = "${var.github_username}"
}

resource "github_actions_secret" "mysql_query_lambda_github_token" {
  repository      = "${github_repository.mysql_query_lambda.name}"
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = "${var.github_token}"
}
