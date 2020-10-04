resource "github_team" "dataworks" {
  name    = "DataWorks"
  privacy = "closed"
}

locals {
  common_labels = [
    {
      name   = "invalid"
      colour = "000000"
    }
  ]
}
