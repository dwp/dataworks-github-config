variable "aws_concourse_domain_name" {
  type        = string
  description = "Concource CI domain name"
  default     = "ci.dataworks.dwp.gov.uk"
}

variable "aws_concourse_team" {
  type        = string
  description = "Concource CI team name"
  default     = "dataworks"
}

variable "github_organization" {
  type        = string
  description = "GitHub Organisation to create repos in"
  default     = "dwp"
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token for managing repos and committing code"
}

variable "github_email" {
  type        = string
  description = "GitHub Email Address for committing code"
}

variable "github_username" {
  type        = string
  description = "GitHub Username for committing code"
}

variable "slack_webhook_url" {
  type        = string
  description = "The webhook URL to send to Slack"
}

variable "dockerhub_username" {
  type        = string
  description = "DockerHub Username to provide to GitHub actions"
}

variable "dockerhub_password" {
  type        = string
  description = "DockerHub Password or Access Token to provide to GitHub actions"
}

variable "snyk_token" {
  type        = string
  description = "Snyk Token to provide to GitHub Actions"
}

variable "terraform_12_version" {
  type        = string
  description = "The current version of tf12"
}

variable "terraform_13_version" {
  type        = string
  description = "The current version of tf13"
}

variable "github_webhook_token" {
  type        = string
  description = "GitHub token to auth with CI"
}

variable "gha_aws_concourse" {
  type = object({
    access_key_id     = string
    secret_access_key = string
  })
  description = "AWS access key and secret for GitHub Actions aws-concourse deployment"
}
