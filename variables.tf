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
