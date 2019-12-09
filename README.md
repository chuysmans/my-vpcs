# my-vpcs
Landscape of VPCs (prod, staging, test)


## How to have your workspace variables in TF for TFE

git clone git@github.com:terraform-aws-modules/terraform-aws-vpc.git

Usage Example...

Lets start with something simple like the public module for a VPC.
Then, lets assume that we want that same module to be consumed across Test, Staging and Production - with a differing set of variables for each.

```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

To keep things simple, I am going to test the theory first and then get more complex to truly make this module DRY for my use case.

I'll place this module into main.tf, then create a variables.tf to build my variables map.

The key piece of the variables file will be a map, that defines per environment, configuration specific variables. Hopefully, it will look something like "If this is the test environment, then use these variables". Where I will have the same style statement for prod and staging.

```
variable "configuration" {
  default = {
    test = { # TEST VARIABLES
      name = "Test"
    }
    staging = { # STAGING VARIABLES
      name = "Staging"
    }
    production = { # PRODUCTION VARIABLES
      name = "Production"
    }
  }
}
```

This will be the basis for the rest of the map... Now I can start updating my main.tf to use variable interpolation:

main.tf
```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = ""${lookup(var.configuration, var.environment).name}""
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```
The key value here is `name`. Essential I am asking Terraform to lookup the configuration map, then find the match to the environment variable and then find the variable called name. This should match to each environemnt.

Finally, I will need a way to denote each workspace within TFC.

```
variable "environment" {
    default = "test"
}
```

the variable called `environment` will be used. Within TFC, for each workspace that I setup, I will create a single variable that will contain the name of the environment. This will help in my configuration map created earlier.

This is all that you need to get started. You can view the rest of the files in this directory to see a more fleshed out example.
