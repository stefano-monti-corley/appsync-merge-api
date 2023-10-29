# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# We override the terraform block source attribute here just for the QA environment to show how you would deploy a
# different version of the module in a specific environment.



# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}


include "vars" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/variables.hcl"
  expose = true
}


# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/dynamodb-table/aws?version=4.0.0"
}


inputs = {

  name     = "tickets-table"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]


}


# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.