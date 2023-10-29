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

dependency "appsync" {
  config_path = "../appsync"
  mock_outputs = {
    appsync_graphql_api_id = "appsync_graphql_api_id"
  }

}


# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.

terraform {
  source = "${get_repo_root()}/modules/appsync-source-association"
}


inputs = {

  merged_api_identifier = "z5ii23ydjrhwfn27r7llt4qbrm"
  source_api_identifier = dependency.appsync.outputs.appsync_graphql_api_id
  merge_type            = "AUTO_MERGE"
  merge_api_role_name   = "appsync-mergedapi-muwGySQ2tMdh"
  region                = include.vars.locals.aws_region
  aws_account_id        = include.vars.locals.account_id


}


# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.