# Terraform

This directory holds the terraform module for maintaining the system infrastructure and deploying the application.

## Terraform State Credentials

The `bootstrap` module is used to create resources that must be created by an individual developers credentials before automation can be run:

* service account and credentials to provide to the CI/CD pipeline to perform future updates

### Initial CI/CD pipeline setup

These steps only need to be run once per project.

1. `cd bootstrap`
1. Run `./setup_shadowenv.sh`
1. Add any users who should have access to the management space to `users.auto.tfvars`
1. Run `./apply.sh`
1. Setup your CI/CD Pipeline to run terraform and deploy your staging and production environments
    1. Copy the `cf_user` and `cf_password` credentials from `secrets.<env>.tfvars` to your CI/CD secrets using the instructions in the base README
1. Delete `secrets.<env>.tfvars`
1. Delete `.shadowenv.d/500_tf_backend_secrets.lisp` if you won't be running terraform locally

### To make changes to the bootstrap module

*This should not be necessary in most cases, other than adding or removing users who should have access to the mgmt space in `bootstrap/users.auto.tfvars`*

1. Make your changes
1. Run `./apply.sh` and verify the plan before entering `yes`

## Set up a sandbox environment or review app

### Steps:

1. Run `./bootstrap/setup_shadowenv.sh`
1. Create a new `sandbox-<NAME>.tfvars` file to hold variable values for your environment. A good starting point is copying `staging.tfvars` and editing it with your values
1. Add a `cf_user = "your.email@gsa.gov"` line to the `sandbox-<NAME>.tfvars` file

1. Run terraform plan with:
    ```bash
    ./terraform.sh -e sandbox-<NAME>
    ```

1. Apply changes with:
    ```bash
    ./terraform.sh -e sandbox-<NAME> -c apply
    ```

1. Optional: tear down the sandbox if it does not need to be used anymore
    ```bash
    ./terraform.sh -e sandbox-<NAME> -c destroy
    ```

## Structure

```
|- bootstrap/
|  |- main.tf
|  |- apply.sh
|  |- users.auto.tfvars
|  |- setup_shadowenv.sh
|  |- bot_secrets.tftpl
|- dist/
|  |- src.zip (automatically generated)
|- README.md
|- app.tf
|- main.tf
|- providers.tf
|- terraform.sh
|- variables.tf
|- <env>.tfvars
```

In the root module:
- `<env>.tfvars` is where to set variable values for the given environment name
- `terraform.sh` Helper script to setup terraform to point to the correct state file, create a service account to run the root module, and apply the root module.
- `app.tf` defines the application resource and configuration
- `main.tf` defines the persistent infrastructure
- `providers.tf` lists the required providers and shell backend config
- `variables.tf` lists the variables that will be needed

In the bootstrap module:
- `main.tf` sets up a management space, an s3 bucket to store terraform state files, and an initial SpaceDeployer for the system
- `apply.sh` Helper script to setup terraform and call `terraform apply`. Any arguments are passed through to the `apply` call
- `users.auto.tfvars` this file defines the list of cloud.gov accounts that should have access to the management space
- `setup_shadowenv.sh` helper script to set terraform backend values using the gitlab http backend in shadowenv
