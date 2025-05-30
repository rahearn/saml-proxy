SAML Proxy
========================

The SAML Proxy bridges authentication requests between a SAML Service Provider (client) and an OpenID Connect IdP.

It does this as a stateless set of redirects to usher the user from one side to the other and back, and must be explicitely
configured with both the client and server sides, so it cannot be used as an open proxy.

## Development

If you're new to Rails, see the [Getting Started with Rails](https://guides.rubyonrails.org/getting_started.html)
guide for an introduction to the framework.

### Local Setup

* Install Ruby 3.4.4
* Install homebrew dependencies: `brew bundle`
  * [shadowenv](https://shopify.github.io/shadowenv/)
  * [Dockerize](https://github.com/jwilder/dockerize)
  * [jq](https://stedolan.github.io/jq/)
  * [ADR Tools](https://github.com/npryce/adr-tools)
* Install Ruby dependencies: `bundle install`
* Run the server: `bin/dev`
* Visit the site: http://localhost:3000

### Local Configuration

Environment variables can be set in development using the [dotenv](https://github.com/bkeepers/dotenv) gem.

Consistent but sensitive credentials should be added to `config/credentials.yml.enc` by using `$ rails credentials:edit`

Production credentials should be added to `config/credentials/production.yml.enc` by using `$ rails credentials:edit --environment production`

Any changes to variables in `.env` that should not be checked into git should be set
in `.env.local`.

If you wish to override a config globally for the `test` Rails environment you can set it in `.env.test.local`.
However, any config that should be set on other machines should either go into `.env` or be explicitly set as part
of the test.

## Security

### Authentication

SAML Proxy has no user accounts itself. It directs users to cloud.gov UAA for authentication and then forwards that
information to the configured `service_provider`s

### Inline `<script>` and `<style>` security

The system's Content-Security-Policy header prevents `<script>` and `<style>` tags from working without further
configuration. Use `<%= javascript_tag nonce: true %>` for inline javascript.

See the [CSP compliant script tag helpers](./doc/adr/0004-rails-csp-compliant-script-tag-helpers.md) ADR for
more information on setting these up successfully.

## Testing

### Running tests

* Tests: `bundle exec rake spec`
* Ruby linter: `bundle exec rake standard`
* Dynamic security scan: `./bin/owasp-scan`
* Ruby static security scan: `bundle exec rake brakeman`
* Ruby dependency checks: `bundle exec rake bundler:audit`

Run everything: `bundle exec rake`

### Automatic linting and terraform formatting
To enable automatic ruby linting and terraform formatting on every `git commit` follow the instructions at the top of `.githooks/pre-commit`

## CI/CD

GitLab CI is used to run all tests and scans as part of pull requests.

Security scans are also run on a scheduled basis. DEVELOPER TODO: create a pipeline schedule in the GitLab UI and update this sentence with the cadence.

### Deployment

Terraform is used to deploy the application and supporting services. See [terraform/README.md](./terraform/README.md)
for more information on how to set up your terraform backend and deploy the app.

#### Staging

Deploys to staging happen via terraform on every push to the `main` branch in GitLab.

The following secrets must be set within the masked and hidden [CI/CD variables](https://docs.gitlab.com/ci/variables/)

| Secret Name | Description |
| ----------- | ----------- |
| `CF_USERNAME` | cloud.gov SpaceDeployer username |
| `CF_PASSWORD` | cloud.gov SpaceDeployer password |
| `STAGING_RAILS_MASTER_KEY` | `config/credentials/staging.key` |


#### Production

Deploys to production happen via terraform on every push to the `production` branch in GitLab.

The following secrets must be set within the masked and hidden [CI/CD variables](https://docs.gitlab.com/ci/variables/)

| Secret Name | Description |
| ----------- | ----------- |
| `CF_USERNAME` | cloud.gov SpaceDeployer username |
| `CF_PASSWORD` | cloud.gov SpaceDeployer password |
| `PRODUCTION_RAILS_MASTER_KEY` | `config/credentials/production.key`. Should be marked as `Protected`. |


### Configuring ENV variables in cloud.gov

All configuration that needs to be added to the deployed application's ENV should be added to
the `environment = {}` block in `terraform/app.tf`

Items that are both **public** and **consistent** across environments can be set directly there.

Otherwise:

1. add a new `variable "variable_name" {}` block to `terraform/variables.tf`
2. add a new entry in the `environment = {}` block to reference that variable
3. set that variable depending on sensitivity:

#### Credentials and other Secrets

1. Store variables that must be secret using masked and hidden [CI/CD variables](https://docs.gitlab.com/ci/variables/) in GitLab
1. Add the appropriate `-var` arguments to the `terraform:plan:<env>` and `terraform:apply:<env>` jobs like the existing `-var rails_master_key=`

#### Non-secrets

Configuration that changes by environment, but is public, should be added to the `tfvars` files, such as `terraform/production.tfvars` and `terraform/staging.tfvars`

### Public Egress Proxy

Traffic to be delivered to the public internet must be proxied through the [cg-egress-proxy](https://github.com/GSA-TTS/cg-egress-proxy) app. Hostnames that the app should be able to
reach should be added to the `allowlist` terraform variable in `terraform/main.tf: module.egress_proxy`

See the [ruby troubleshooting doc](https://github.com/GSA-TTS/cg-egress-proxy/blob/main/docs/ruby.md) first if you have any problems making outbound connections through the proxy.

## Documentation

### Architectural Decision Records

Architectural Decision Records (ADR) are stored in `doc/adr`
To create a new ADR, first install [ADR-tools](https://github.com/npryce/adr-tools) if you don't
already have it installed.
* `brew bundle` or `brew install adr-tools`

Then create the ADR:
*  `adr new Title Of Architectural Decision`

This will create a new, numbered ADR in the `doc/adr` directory.

Compliance diagrams are stored in `doc/compliance`. See the README there for more information on
generating diagram updates.

## Contributing

*This will continue to evolve as the project moves forward.*

* Pull down the most recent main before checking out a branch
* Write your code
* If a big architectural decision was made, add an ADR
* Submit a PR
  * If you added functionality, please add tests.
  * All tests must pass!
* Ping the other engineers for a review.
* At least one approving review is required for merge.
* Rebase against main before merge to ensure your code is up-to-date!
* Merge after review.
  * Squash commits into meaningful chunks of work and ensure that your commit messages convey meaning.
