# Existing pipeline: https://buildkite.com/bazel-contrib/rules-lint
resource "buildkite_pipeline" "rules_lint" {
  name                       = "rules_lint"
  slug                       = "rules-lint"
  description                = "Run static analysis tools with Bazel"
  repository                 = "https://github.com/bazel-contrib/rules_lint.git"
  cluster_id                 = "Q2x1c3Rlci0tLTAzZWEwNWYxLTM5Y2QtNGQwYy1iZWZhLWVkNmQ1Mjc2YjIzOQ=="
  default_branch             = "main"
  branch_configuration       = "main"
  visibility                 = "PUBLIC"
  color                      = "#FFDAB9"
  emoji                      = ":ladybug:"
  allow_rebuilds             = true
  skip_intermediate_builds   = false
  cancel_intermediate_builds = false
  steps                      = chomp(file("${path.module}/pipelines/rules-lint.yml"))

  provider_settings = {
    build_branches                                      = false
    build_check_run_completed                           = false
    build_create_event                                  = false
    build_deployment_status_created                     = false
    build_issue_comment_created                         = false
    build_issues                                        = false
    build_merge_group_checks_requested                  = false
    build_pull_request_base_branch_changed              = false
    build_pull_request_converted_to_draft               = false
    build_pull_request_dequeued                         = false
    build_pull_request_edited                           = false
    build_pull_request_review_comment_created           = false
    build_pull_request_forks                            = true
    build_pull_request_labels_changed                   = false
    build_pull_request_ready_for_review                 = false
    build_pull_request_reopened                         = false
    build_pull_request_merge_commits                    = false
    build_pull_request_review_dismissed                 = false
    build_pull_request_review_requested                 = false
    build_pull_request_review_submitted                 = false
    build_pull_request_stacks                           = false
    build_pull_requests                                 = true
    build_release_created                               = false
    build_release_published                             = false
    build_release_released                              = false
    build_tags                                          = false
    cancel_deleted_branch_builds                        = false
    cancel_when_merge_group_destroyed                   = false
    github_workflow_access_tokens_enabled               = true
    filter_enabled                                      = false
    ignore_default_branch_pull_requests                 = false
    issue_comment_command_word                          = "/bk"
    issue_comment_match_mode                            = "exact"
    prefix_pull_request_fork_branch_names               = true
    prevent_custom_statuses_from_using_buildkite_prefix = true
    publish_blocked_as_pending                          = true
    publish_commit_status_per_step                      = false
    publish_commit_status                               = true
    pull_request_branch_filter_enabled                  = false
    review_comment_command_word                         = "/bk"
    review_comment_match_mode                           = "exact"
    separate_pull_request_statuses                      = false
    skip_builds_for_closed_pull_requests                = false
    skip_builds_for_existing_commits                    = false
    skip_pull_request_builds_for_existing_commits       = false
    trigger_mode                                        = "code"
    use_merge_group_base_commit_for_git_diff_base       = false
    use_step_key_as_commit_status                       = false
    filter_condition                                    = ""
    pull_request_branch_filter_configuration            = ""
  }

  lifecycle {
    prevent_destroy = true
  }
}
