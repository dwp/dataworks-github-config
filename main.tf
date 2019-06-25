resource "github_team" "dataworks" {
  name = "DataWorks"
  privacy = "closed"
}

variable "wip-label-colour" {
  default = "f4b342"
}
