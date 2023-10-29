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

dependency "dynamodd_table_users" {
  config_path = "../dynamo-table-users"
  skip_outputs = true
}


# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/appsync/aws?version=2.3.0"
}


inputs = {

  name   = "users_apis"
  schema = file("${get_repo_root()}/src/users/schema.graphql")
  api_keys = {
    default = null # such key will expire in 7 days
  }
  logging_enabled = true
  log_field_log_level = "ALL"
  datasources = {
    dynamodb_users_table = {
      type       = "AMAZON_DYNAMODB"
      table_name = "users-table"
      region     = include.vars.locals.aws_region
    }
  }
  resolvers = {
    "Query.singleUser" = {
      kind  = "UNIT"
      type  = "Query"
      field = "singleUser"
      code  = file("${get_repo_root()}/src/users/resolvers/getSingleUser.js")
      runtime = {
        name            = "APPSYNC_JS"
        runtime_version = "1.0.0"
      }
      data_source = "dynamodb_users_table"
    }
    "Ticket.user" = {
      kind  = "UNIT"
      type  = "Ticket"
      field = "user"
      code  = file("${get_repo_root()}/src/users/resolvers/getUserByUserId.js")
      runtime = {
        name            = "APPSYNC_JS"
        runtime_version = "1.0.0"
      }
      data_source = "dynamodb_users_table"
    }
  }

}


# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.