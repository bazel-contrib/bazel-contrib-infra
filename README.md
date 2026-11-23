# bazel-contrib Buildkite

Minimal OpenTofu configuration for https://buildkite.com/bazel-contrib.

- `main.tf`: organization two-factor requirement; existing IP policies stay unmanaged.
- `pipelines.tf`: existing `rules-lint` pipeline and GitHub trigger settings.
- `pipelines/rules-lint.yml`: exact bootstrap YAML captured from Buildkite.
- `imports.tf`: adopt the existing organization and pipeline instead of creating duplicates.

The pipeline stays public, limits branches to `main`, and keeps pull requests from
forks enabled. Its bootstrap runs `.buildkite/pipeline.py` from the `rules_lint`
repository, which generates the remaining build steps. Existing cluster, team
access, webhooks, and agent infrastructure stay outside this configuration.

## Use

Install OpenTofu 1.11 or newer. The official `buildkite/buildkite` provider needs
an organization administrator's API token authorized for `bazel-contrib` with:

- `graphql`
- `read_pipelines` and `write_pipelines`
- `read_organization_settings` and `write_organization_settings`

```sh
export BUILDKITE_API_TOKEN="$(cat /tmp/buildkite-token)"
tofu init
tofu plan -out=buildkite.tfplan
# Review the plan. Initial adoption should import two resources with no changes.
tofu apply buildkite.tfplan
unset BUILDKITE_API_TOKEN
```

No remote changes have been applied. The import blocks can remain after adoption.
The supplied token currently lacks the two organization-settings scopes above;
API/browser policy reads produce warnings until those are added. The two-factor
requirement was read through GraphQL and matches current settings.
Review the first plan carefully: provider defaults or settings unavailable through
the REST API may need matching before applying. The two-factor requirement
matches the captured current value (`false`). New pipelines need an initial
`default_team_id` and repository webhook setup in addition to a pipeline resource.

Commit `.terraform.lock.hcl`. State uses the local backend; keep it private and
backed up. Configure shared state with locking before multiple people or CI apply
changes. State, saved plans, local variable values, and credentials are ignored.
The resource lifecycle blocks protect against deletion while their resource
blocks remain in configuration.

## Provider reference

- [Authentication](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/index.md)
- [Organization settings](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/resources/organization.md)
- [Pipelines](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/resources/pipeline.md)

## Local verification

On the setup computer, `github.com` connections time out, including provider
checksum downloads during `tofu init`. Verification uses a temporary filesystem
mirror populated through GitHub's official release-assets API, with archive
SHA256 checks against the official checksum file. The mirror stays outside this
repository; normal use keeps the standard OpenTofu registry source. The lock file
includes checksums for macOS ARM64 and Linux AMD64.

Verified with OpenTofu 1.13.9: format check and schema validation pass. The import
plan reports **2 to import, 0 to add, 0 to change, 0 to destroy**, with warnings
for the token's missing organization-settings read scope. No apply was run.
