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
  common_topics = [
    "govuk",
    "hactoberfest",
  ]
  aws_topics = [
    "aws",
    "terraform",
    "infrastructure",
    "infrastructure-as-code",
  ]
}
