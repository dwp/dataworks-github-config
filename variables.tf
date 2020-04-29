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
