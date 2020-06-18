variable "dockerhub_username" {
  type        = "string"
  description = "DockerHub Username to provide to GitHub actions"
}

variable "dockerhub_password" {
  type        = "string"
  description = "DockerHub Password or Access Token to provide to GitHub actions"
}

variable "snyk_token" {
  type        = "string"
  description = "Snyk Token to provide to GitHub Actions"
}

variable "github_webhook_token" {
  type        = "string"
  description = "GitHub token to auth with CI"
}

variable "aws_concourse_domain_name" {
  type        = "string"
  description = "Concource CI domain name"
  default     = "ci.dataworks.dwp.gov.uk"
}

variable "aws_concourse_team" {
  type        = "string"
  description = "Concource CI team name"
  default     = "dataworks"
}

variable "github_token" {
  type        = "string"
  description = "GitHub personal access token for managing repos and committing code"
}

variable "github_email" {
  type        = "string"
  description = "GitHub Email Address for committing code"
}

variable "github_username" {
  type        = "string"
  description = "GitHub Username for committing code"
}

variable "github_organization" {
  type        = "string"
  description = "GitHub Organisation to create repos in"
}
