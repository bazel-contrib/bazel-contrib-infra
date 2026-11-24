# Declarative imports adopt existing resources on the first apply.
import {
  to = buildkite_organization.settings
  id = "bazel-contrib"
}

import {
  to = buildkite_pipeline.pipelines["rules-lint"]
  id = "UGlwZWxpbmUtLS0wMWExYzc0MS1kYmExLTQwNDUtODk2OS1lMzJkNmIyMzM4NWE="
}
