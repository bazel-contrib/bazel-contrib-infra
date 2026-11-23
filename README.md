# bazel-contrib Buildkite

Minimal OpenTofu configuration for https://buildkite.com/bazel-contrib.

- `main.tf`: organization settings.
- `pipelines.tf`: shared defaults, per-pipeline appearance, team lookup, and webhooks.
- `pipelines/*.yml`: bootstrap templates, named after each pipeline slug.
- `pipelines/bazelci.yq`: buildtools presubmit-to-Buildkite transform.
- `imports.tf`: adopt the existing organization and `rules-lint` pipeline.

Repository entries override shared defaults; nested `provider_settings` merge
individually. Each pipeline chooses its own color and emoji. Add a repository to
`local.pipelines` and a matching bootstrap template to add another pipeline.
Comments explain less obvious settings using the pinned provider's
[pipeline documentation](https://github.com/buildkite/terraform-provider-buildkite/blob/v1.48.0/docs/resources/pipeline.md).

`rules-lint` keeps its bootstrap and existing team/webhook assignments.
`buildtools` gets the `everyone` team's initial access and a GitHub App webhook.
The App must have access to `bazel-contrib/buildtools`.

Terraform embeds `pipelines/bazelci.yq` into the buildtools bootstrap using
`templatefile()`. At build time, Mike Farah yq v4 reads the checked-out
`.bazelci/presubmit.yml` and generates buildifier plus one test step per platform.
The transform preserves test flags and target exclusions, normalizes the target
separator, and shell-quotes each argument. The second upload disables variable
interpolation so generated shell arguments stay literal.

The transform covers buildtools' current presubmit format, not BazelCI's full
matrix/import/setup/sharding feature set. It uses the upstream buildifier image
and BazelCI's test-only/flaky-test flags, without Google-specific caching or cloud
credentials. This avoids BazelCI's fixed organization/cloud-project mapping.

Queue mapping is explicit in the expression: `ubuntu2204` uses `default`, while
`macos`, `macos_arm64`, and `windows` use queues of the same name. These queues
must exist and provide the intended OS/architecture; the default queue must have
a suitable Linux environment. Test agents need Bazelisk and repository build
tools. Windows agents need Bash as their command shell for the generated POSIX
quoting. The setup agent needs yq v4 with `@sh` support; buildifier needs Docker.

Buildkite MCP returned `No organization found` for both organizations. Queue and
team access remain unverified; refresh the connection before planning.

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
# Review imports and new buildtools resources.
tofu apply buildkite.tfplan
unset BUILDKITE_API_TOKEN
```

No remote changes have been applied. The import blocks can remain after adoption.
The supplied token currently lacks the two organization-settings scopes above;
API/browser policy reads produce warnings until those are added. The two-factor
requirement was read through GraphQL and matches current settings.
Review the first plan carefully: provider defaults or settings unavailable through
the REST API may need matching before applying. The two-factor requirement
matches the captured current value (`false`). The buildtools configuration includes its initial team and repository webhook.

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

OpenTofu 1.13.9 formatting and schema validation pass. No live plan or apply was
run for these changes. Local template rendering and shell syntax are checked;
yq is not installed locally, so the transform has not been executed here.
