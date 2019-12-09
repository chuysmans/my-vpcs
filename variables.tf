#
# The name of the environment, should be set on the TFC workspace
#
variable "environment" {
    default = "test"
}

#
# Contains the configuration based on the environment variable.
# The name of the environment is the key for the map see outputs.tf
# for an example of how to lookup and reference this variables :)
#
variable "configuration" {
  default = {
    test = {
      size = "a1.medium",
      name = "test",
      vpc_cidr = "10.2.0.0/16",
      nat_gateway = "true"
    }
    staging = {
      size = "a1.large",
      name = "staging",
      vpc_cidr = "10.1.0.0/16",
      nat_gateway = "true"
    }
    production = {
      size = "a1.xlarge",
      name = "production",
      vpc_cidr = "10.0.0.0/16",
      nat_gateway = "false"
    }
  }
}
