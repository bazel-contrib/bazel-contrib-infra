# bazel-contrib Buildkite

OpenTofu configuration for [bazel-contrib on Buildkite](https://buildkite.com/bazel-contrib).

## Configuration

- `main.tf`: organization settings; IP policies are unmanaged.
- `pipelines.tf`: shared defaults, repository settings, team lookup, and webhooks.
- `pipelines/*.yml`: pipeline YAML files, named after each pipeline slug.
- `imports.tf`: declarative imports identifying the organization and `rules-lint` pipeline.

Repository entries override shared defaults; nested `provider_settings` merge
individually. Each pipeline specifies its own color and emoji. Comments explain
less obvious settings using the provider documentation linked below.

To add a pipeline, add a repository entry to `local.pipelines` and a matching
`pipelines/<slug>.yml` pipeline YAML file. Set `default_team_id` for creation and
`create_webhook = true` to manage its GitHub App webhook. The initial team gets
Manage Build and Read access; further team associations require separate management.
The Buildkite GitHub App must have access to repositories with managed webhooks.

## Use

Install OpenTofu >= 1.11 and < 2.0. The `buildkite/buildkite` provider needs an
organization administrator API token authorized for `bazel-contrib` with:

- `graphql`
- `read_pipelines` and `write_pipelines`
- `read_organization_settings` and `write_organization_settings`

Set `BUILDKITE_API_TOKEN` through your credential manager or shell environment,
then run:

```sh
tofu init
tofu plan -out=buildkite.tfplan
# Review the saved plan before applying.
tofu apply buildkite.tfplan
```

Declarative import blocks associate resources with their Buildkite identities
and can remain after import. Check the plan for unintended changes to provider
settings, team assignments, and webhooks before applying.

Commit `.terraform.lock.hcl`. State uses the local backend; keep it private and
backed up. Configure shared state with locking before multiple people or CI apply
changes. State, saved plans, local variable values, and credentials are ignored.
Resource lifecycle blocks prevent deletion while their resource blocks remain
in configuration.

## Validation

```sh
tofu init
tofu fmt -check -recursive
tofu validate
```

Validate queue availability and agent prerequisites for each pipeline in
Buildkite before running builds.

## Provider reference

- [Authentication](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/index.md)
- [Organization settings](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/resources/organization.md)
- [Pipelines](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/resources/pipeline.md)
