terraform {
  cloud {
    organization = "macakcompany"

    workspaces {
      name = "terraform-bootcamp"
    }
  }
}