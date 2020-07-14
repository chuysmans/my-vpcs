#
# The name of the environment, should be set on the TFC workspace
#
variable "environment" {
    default = "dev"
}

variable "owner" {
    default = "Moayad Ismail"
}

variable "ttl" {
    default  = "8"
}


#
# Contains the configuration based on the environment variable.
# The name of the environment is the key for the map see outputs.tf
# for an example of how to lookup and reference this variables :)
#
variable "configuration" {
  default = {
    dev = { # TEST VARIABLES
      size = "a1.medium",
      name = "Test",
      vpc_cidr = "10.2.0.0/16",
      nat_gateway = "false",
      vpn_gateway = "false"
    }
    test = { # STAGING VARIABLES
      size = "a1.large",
      name = "Staging",
      vpc_cidr = "10.1.0.0/16",
      nat_gateway = "false",
      vpn_gateway = "false"
    }
    prod = { # PRODUCTION VARIABLES
      size = "a1.xlarge",
      name = "Production",
      vpc_cidr = "10.0.0.0/16",
      nat_gateway = "false"
      vpn_gateway = "false"
    }
  }
}
