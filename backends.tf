terraform {
  cloud {
    organization = "webatspeed"

    workspaces {
      name = "webatspeed-prod"
    }
  }
}
