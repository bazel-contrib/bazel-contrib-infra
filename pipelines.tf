locals {
  pipeline_defaults = {
    # Default cluster provided by Buildkite, with their hosted runners
    cluster_id     = "Q2x1c3Rlci0tLTAzZWEwNWYxLTM5Y2QtNGQwYy1iZWZhLWVkNmQ1Mjc2YjIzOQ=="
    default_branch = "main"
    # Branch-push filter; pull requests use their separate filter below.
    branch_configuration = "main"
    visibility           = "PUBLIC"
    allow_rebuilds       = true
    # Skip queued builds superseded by another commit on the same branch.
    skip_intermediate_builds = false
    # Cancel running builds superseded by another commit on the same branch.
    cancel_intermediate_builds = false
    # Initial team gets Manage Build and Read access; null leaves imported access unchanged.
    default_team_id = null
    # Create a GitHub App webhook for this repository through Buildkite.
    create_webhook = false
    provider_settings = {
      build_branches = false
      # Trigger when a GitHub check run finishes, for chaining CI systems.
      build_check_run_completed = false
      # Trigger when GitHub creates a branch or tag.
      build_create_event = false
      # Trigger on a new GitHub deployment status.
      build_deployment_status_created = false
      # Trigger from comments on pull requests, using the command word below.
      build_issue_comment_created = false
      # Trigger on authenticated GitHub issues webhook events.
      build_issues = false
      # Trigger required checks for GitHub merge queue groups.
      build_merge_group_checks_requested     = false
      build_pull_request_base_branch_changed = false
      build_pull_request_converted_to_draft  = false
      # Trigger when a pull request leaves the merge queue; requires PR builds.
      build_pull_request_dequeued = false
      # Trigger on pull request title or description edits.
      build_pull_request_edited                 = false
      build_pull_request_review_comment_created = false
      # Allow pull request builds from third-party forks.
      build_pull_request_forks            = true
      build_pull_request_labels_changed   = false
      build_pull_request_ready_for_review = false
      build_pull_request_reopened         = false
      # Test the synthetic merge with the base branch instead of the PR head.
      build_pull_request_merge_commits    = false
      build_pull_request_review_dismissed = false
      build_pull_request_review_requested = false
      build_pull_request_review_submitted = false
      # Trigger when a pull request is added to a stack; requires PR builds.
      build_pull_request_stacks = false
      build_pull_requests       = true
      # Includes newly created draft releases.
      build_release_created = false
      # Trigger when a GitHub release is published.
      build_release_published = false
      # Trigger on non-prerelease publication, excluding drafts and prereleases.
      build_release_released       = false
      build_tags                   = false
      cancel_deleted_branch_builds = false
      # Cancel running builds for a merge group removed from the queue.
      cancel_when_merge_group_destroyed = false
      # Allow jobs to request GitHub tokens constrained by workflow permissions.
      github_workflow_access_tokens_enabled = true
      # Apply filter_condition before creating builds.
      filter_enabled = false
      # Prevent caching PRs whose source branch is the default branch.
      ignore_default_branch_pull_requests = false
      # Command that requests a build in a pull request conversation comment.
      issue_comment_command_word = "/bk"
      # Require the entire trimmed comment to match, ignoring case.
      issue_comment_match_mode = "exact"
      # Represent fork branches as owner:branch so branch filters distinguish them.
      prefix_pull_request_fork_branch_names = true
      # Reserve buildkite/ status contexts when the organization also enforces this.
      prevent_custom_statuses_from_using_buildkite_prefix = true
      # Report blocked builds as pending to repository status checks.
      publish_blocked_as_pending = true
      # Publish a repository commit status for each job.
      publish_commit_status_per_step = false
      # Publish the overall build status to the repository provider.
      publish_commit_status = true
      # Apply the PR-specific branch filter independently of branch_configuration.
      pull_request_branch_filter_enabled = false
      # Command that requests a build in an inline pull request review comment.
      review_comment_command_word = "/bk"
      # Require the entire trimmed review comment to match, ignoring case.
      review_comment_match_mode = "exact"
      # Give pull request builds a distinct repository status context.
      separate_pull_request_statuses       = false
      skip_builds_for_closed_pull_requests = false
      # Suppress duplicate builds for the same commit and branch.
      skip_builds_for_existing_commits = false
      # Suppress PR builds if the commit and branch already have a build.
      skip_pull_request_builds_for_existing_commits = false
      # Use GitHub code events rather than deployment or fork events.
      trigger_mode = "code"
      # Use the previous merge group as the diff base for agent if_changed checks.
      use_merge_group_base_commit_for_git_diff_base = false
      # Name per-job commit statuses after step keys; requires per-step status publishing.
      use_step_key_as_commit_status = false
      # Buildkite expression evaluated only when filter_enabled is true.
      filter_condition = ""
      # Branch pattern evaluated only when the PR branch filter is enabled.
      pull_request_branch_filter_configuration = ""
    }
  }

  # Add repositories here. Override shared settings only when needed.
  pipelines = {
    rules-lint = {
      color       = "#FFDAB9"
      emoji       = ":ladybug:"
      name        = "rules_lint"
      description = "Run static analysis tools with Bazel"
      repository  = "https://github.com/bazel-contrib/rules_lint.git"
    }
    rules-python = {
      color       = "#3776AB"
      emoji       = ":python:"
      name        = "rules_python"
      description = "Build and test Bazel Python rules"
      repository  = "https://github.com/bazel-contrib/rules_python.git"
      # Initial team gets Manage Build and Read access; null leaves imported access unchanged.
      default_team_id = data.buildkite_team.everyone.id
      # Create a GitHub App webhook for this repository through Buildkite.
      create_webhook = true
    }
    tar-bzl = {
      color       = "#D1C4E9"
      emoji       = ":package:"
      name        = "tar.bzl"
      description = "Build and test Bazel tar archive rules"
      repository  = "https://github.com/bazel-contrib/tar.bzl.git"
      # Initial team gets Manage Build and Read access; null leaves imported access unchanged.
      default_team_id = data.buildkite_team.everyone.id
      # Create a GitHub App webhook for this repository through Buildkite.
      create_webhook = true
    }
  }

  pipeline_settings = {
    for slug, settings in local.pipelines : slug => merge(local.pipeline_defaults, settings, {
      provider_settings = merge(local.pipeline_defaults.provider_settings, try(settings.provider_settings, {}))
    })
  }
}

# New pipelines need an initial team. Existing pipeline team access stays unmanaged.
data "buildkite_team" "everyone" {
  slug = "everyone"
}

resource "buildkite_pipeline" "pipelines" {
  for_each = local.pipeline_settings

  name                       = each.value.name
  slug                       = each.key
  description                = each.value.description
  repository                 = each.value.repository
  cluster_id                 = each.value.cluster_id
  default_branch             = each.value.default_branch
  branch_configuration       = each.value.branch_configuration
  visibility                 = each.value.visibility
  color                      = each.value.color
  emoji                      = each.value.emoji
  allow_rebuilds             = each.value.allow_rebuilds
  skip_intermediate_builds   = each.value.skip_intermediate_builds
  cancel_intermediate_builds = each.value.cancel_intermediate_builds
  default_team_id            = each.value.default_team_id
  provider_settings          = each.value.provider_settings
  steps                      = chomp(file("${path.module}/pipelines/${each.key}.yml"))

  lifecycle {
    prevent_destroy = true
  }
}

resource "buildkite_pipeline_webhook" "pipelines" {
  for_each = { for slug, settings in local.pipeline_settings : slug => settings if settings.create_webhook }

  pipeline_id = buildkite_pipeline.pipelines[each.key].id
  repository  = each.value.repository
}
