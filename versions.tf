terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    buildkite = {
      source  = "buildkite/buildkite"
      version = "~> 1.48.0"
    }
  }
}

provider "buildkite" {
  organization = "bazel-contrib"
  # Authentication: BUILDKITE_API_TOKEN environment variable.
}
