# bazel-contrib Buildkite

OpenTofu configuration for [bazel-contrib on Buildkite](https://buildkite.com/bazel-contrib).

## Configuration

- `main.tf`: organization settings; IP policies are unmanaged.
- `pipelines.tf`: shared defaults, repository settings, team lookup, and webhooks.
- `pipelines/*.yml`: bootstrap templates, named after each pipeline slug.
- `pipelines/bazelci.yq`: buildtools presubmit-to-Buildkite transform.
- `imports.tf`: declarative imports identifying the organization and `rules-lint` pipeline.

Repository entries override shared defaults; nested `provider_settings` merge
individually. Each pipeline specifies its own color and emoji. Comments explain
less obvious settings using the provider documentation linked below.

`rules-lint` runs `.buildkite/pipeline.py` from its repository. Its team access and
repository webhook are managed outside this configuration. `buildtools` uses the
`everyone` team for initial access and a GitHub App webhook managed by OpenTofu.
The Buildkite GitHub App must have access to `bazel-contrib/buildtools`.

To add a pipeline, add a repository entry to `local.pipelines` and a matching
`pipelines/<slug>.yml` bootstrap template. Set `default_team_id` for creation and
`create_webhook = true` to manage its GitHub App webhook. The initial team gets
Manage Build and Read access; further team associations require separate management.

## Buildtools presubmit

Terraform embeds `pipelines/bazelci.yq` into the bootstrap with `templatefile()`.
At build time, Mike Farah yq v4 reads the checked-out `.bazelci/presubmit.yml` and
generates buildifier plus one test step per platform. The transform preserves
test flags and target exclusions, normalizes the target separator, and
shell-quotes each argument. Pipeline upload disables variable interpolation so
generated shell arguments stay literal.

The supported input fields are `buildifier.version`, `buildifier.warnings`, and
`platforms.<platform>.test_flags` / `test_targets`. BazelCI matrices, imports,
setup commands, and sharding are unsupported. The transform uses the upstream
buildifier image and BazelCI test-only/flaky-test flags. It runs Bazel directly
because the BazelCI runner assumes organization-specific Google cloud projects,
credentials, and caches.

The expression defines these queue mappings:

| Presubmit platform | Buildkite queue |
| --- | --- |
| `ubuntu2204` | `default` |
| `macos` | `macos` |
| `macos_arm64` | `macos_arm64` |
| `windows` | `windows` |

Provision queues with the corresponding OS and architecture before running the
pipeline. Update the mapping when adding platforms or changing queue names.
Test agents need Bazelisk and repository build tools. Windows agents need Bash
as their command shell for POSIX quoting. The setup agent needs Mike Farah yq v4
with `@sh` support; the buildifier step needs Docker.

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

To inspect generated jobs against a buildtools checkout:

```sh
yq --from-file pipelines/bazelci.yq /path/to/buildtools/.bazelci/presubmit.yml
```

Review the output for platform queues, test flags, target exclusions, and the
buildifier configuration. Validate queue availability and agent prerequisites
in Buildkite before running builds.

## Provider reference

- [Authentication](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/index.md)
- [Organization settings](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/resources/organization.md)
- [Pipelines](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/resources/pipeline.md)
