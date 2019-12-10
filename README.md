# Terraform Cloud Variables (Multiple workspaces per repo with local variables file)
A working example of how to have a Terraform code base in a single repo, with differing variables for each landscape of your code or application. This is based on the HashiCorp [recommended approach to managing workspaces in TFC](https://www.terraform.io/docs/cloud/workspaces/repo-structure.html#structuring-repos-for-multiple-environments_)

This guide removes the need to configure a long list of variables outside of you code (VCS), and therefore makes it simpler to keep code and variables within the same repo, managed by the same people in a way that is easy to consume (single workflow)

### Prerequisites
To run this demo or something like it you will need:

1. [Terraform Cloud Account](https://app.terraform.io)
1. GitHub repo
1. [Have your GitHub Account authorised within TFC](https://www.terraform.io/docs/cloud/vcs/github.html)
1. A new GitHub repo for this project
1. Cloud credentials for the workspaces

### Usage Example

Lets start with something simple like the [public module for a VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc).
Then, lets assume that we want that same module to be consumed across Test, Staging and Production - with a differing set of variables for each.


Here is our starting point for consuming the module:
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

To keep things simple, I am going to test the theory first and then get more complex to truly make this module work for my use case.

I'll place this module into main.tf, then create a variables.tf to build my variables map. All these files will live in the same repo that was created as part of the prerequisites

My repo:

```
├── README.md
├── variables.tf
├── main.tf
├── outputs.tf
```

The key piece of the variables file will be a map which defines per environment, configuration specific variables. Hopefully, it will look something like "If this is the test environment, then use these variables". Where I will have the same style statement for prod and staging.

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

This will be the basis for the rest of the map. Now I can start updating my main.tf to use variable interpolation:

main.tf
```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${lookup(var.configuration, var.environment).name}"
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
The key value here is `name`. Essentially I am asking Terraform to lookup the configuration map, then find the match to the environment variable and then find the variable called name. This should match to each environment.

Finally, I will need a way to denote each workspace within TFC.

```
variable "environment" {
    default = "test"
}
```

The variable called `environment` will be used. Within TFC, for each workspace that I setup, I will create a single variable that will contain the name of the environment. This will help in my configuration map created earlier.

Once this is done we can make some additions to TFC. To build out the demo you'll need to:

1. Create a new workspace called `my-vpc-test`
1. Map this new workspace to the recent repo you created with the code above
1. Add our environment variable
  1. `environment` = `test`
1. Add TFC Environment variable for cloud credentials
  1. `AWS_ACCESS_KEY_ID`
  1. `AWS_SECRET_ACCESS_KEY`
1. Select "Queue Plan" for the workspace
1. Repeat these steps for both staging and production

Within TFC, you should now see your three workspaces, all linked to the same repo. Once the initialisation of the workspace (first Queue Plan) is completed, the workspaces will now run speculative plans based on changes to the repo.

This a great way to maintain a single code base, promote code through environments with a single variables file.

Note:
* Code can be promoted by simply discarding the plans which are not required. 
* Within TFC there is currently a soft limit of 1 concurrent plan per cloud account, therefore only one workspace will run the plan at a time.


This is all that you need to get started. You can view the rest of the files in this directory to see a more fleshed out example.
