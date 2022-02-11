---
stage: Verify
group: Pipeline Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# GitLab CI/CD artifacts reports types **(FREE)**

Use [`artifacts:reports`](index.md#artifactsreports) to:

- Collect test reports, code quality reports, security reports, and other artifacts generated by included templates in
  jobs.
- Some of these reports are used to display information in:
  - Merge requests.
  - Pipeline views.
  - [Security dashboards](../../user/application_security/security_dashboard/index.md).

The test reports are collected regardless of the job results (success or failure).
You can use [`artifacts:expire_in`](index.md#artifactsexpire_in) to set up an expiration
date for their artifacts.

Some `artifacts:reports` types can be generated by multiple jobs in the same pipeline, and used by merge request or
pipeline features from each job.

To be able to browse the report output files, include the [`artifacts:paths`](index.md#artifactspaths) keyword.

NOTE:
Combined reports in parent pipelines using [artifacts from child pipelines](index.md#needspipelinejob) is
not supported. Track progress on adding support in [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/215725).

## `artifacts:reports:accessibility`

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/39425) in GitLab 12.8.

The `accessibility` report uses [pa11y](https://pa11y.org/) to report on the accessibility impact
of changes introduced in merge requests.

GitLab can display the results of one or more reports in the merge request
[accessibility widget](../../user/project/merge_requests/accessibility_testing.md#accessibility-merge-request-widget).

For more information, see [Accessibility testing](../../user/project/merge_requests/accessibility_testing.md).

## `artifacts:reports:api_fuzzing` **(ULTIMATE)**

> - Introduced in GitLab 13.4.
> - Requires GitLab Runner 13.4 or later.

The `api_fuzzing` report collects [API Fuzzing bugs](../../user/application_security/api_fuzzing/index.md)
as artifacts.

GitLab can display the results of one or more reports in:

- The merge request [security widget](../../user/application_security/api_fuzzing/index.md#view-details-of-an-api-fuzzing-vulnerability).
- The [Project Vulnerability report](../../user/application_security/vulnerability_report/index.md).
- The pipeline [**Security** tab](../../user/application_security/security_dashboard/index.md#view-vulnerabilities-in-a-pipeline).
- The [security dashboard](../../user/application_security/api_fuzzing/index.md#security-dashboard).

## `artifacts:reports:browser_performance` **(PREMIUM)**

> [Name changed](https://gitlab.com/gitlab-org/gitlab/-/issues/225914) from `artifacts:reports:performance` in GitLab 14.0.

The `browser_performance` report collects [Browser Performance Testing metrics](../../user/project/merge_requests/browser_performance_testing.md)
as artifacts.

GitLab can display the results of one report in the merge request
[browser performance testing widget](../../user/project/merge_requests/browser_performance_testing.md#how-browser-performance-testing-works).

GitLab cannot display the combined results of multiple `browser_performance` reports.

## `artifacts:reports:cluster_image_scanning` **(ULTIMATE)**

> - Introduced in GitLab 14.1.
> - Requires GitLab Runner 14.1 and above.

The `cluster_image_scanning` report collects `CLUSTER_IMAGE_SCANNING` vulnerabilities. The collected
`CLUSTER_IMAGE_SCANNING` report uploads to GitLab as an artifact.

GitLab can display the results of one or more reports in:

- The [security dashboard](../../user/application_security/security_dashboard/index.md).
- The [Project Vulnerability report](../../user/application_security/vulnerability_report/index.md).

## `artifacts:reports:cobertura`

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/3708) in GitLab 12.9.

The `cobertura` report collects [Cobertura coverage XML files](../../user/project/merge_requests/test_coverage_visualization.md).
The collected Cobertura coverage reports upload to GitLab as an artifact.

GitLab can display the results of one or more reports in the merge request
[diff annotations](../../user/project/merge_requests/test_coverage_visualization.md).

Cobertura was originally developed for Java, but there are many third-party ports for other languages such as
JavaScript, Python, and Ruby.

## `artifacts:reports:codequality`

> [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/212499) to GitLab Free in 13.2.

The `codequality` report collects [code quality issues](../../user/project/merge_requests/code_quality.md). The
collected code quality report uploads to GitLab as an artifact.

GitLab can display the results of:

- One or more reports in the merge request [code quality widget](../../user/project/merge_requests/code_quality.md#code-quality-widget).
- Only one report in:
  - The merge request [diff annotations](../../user/project/merge_requests/code_quality.md#code-quality-in-diff-view).
    Track progress on adding support for multiple reports in [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/328257).
  - The [full report](../metrics_reports.md). Track progress on adding support for multiple reports in
    [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/9014).

## `artifacts:reports:container_scanning` **(ULTIMATE)**

The `container_scanning` report collects [Container Scanning vulnerabilities](../../user/application_security/container_scanning/index.md).
The collected Container Scanning report uploads to GitLab as an artifact.

GitLab can display the results of one or more reports in:

- The merge request [container scanning widget](../../user/application_security/container_scanning/index.md).
- The pipeline [**Security** tab](../../user/application_security/security_dashboard/index.md#view-vulnerabilities-in-a-pipeline).
- The [security dashboard](../../user/application_security/security_dashboard/index.md).
- The [Project Vulnerability report](../../user/application_security/vulnerability_report/index.md).

## `artifacts:reports:coverage_fuzzing` **(ULTIMATE)**

> - Introduced in GitLab 13.4.
> - Requires GitLab Runner 13.4 or later.

The `coverage_fuzzing` report collects [coverage fuzzing bugs](../../user/application_security/coverage_fuzzing/index.md).
The collected coverage fuzzing report uploads to GitLab as an artifact.
GitLab can display the results of one or more reports in:

- The merge request [coverage fuzzing widget](../../user/application_security/coverage_fuzzing/index.md#interacting-with-the-vulnerabilities).
- The pipeline [**Security** tab](../../user/application_security/security_dashboard/index.md#view-vulnerabilities-in-a-pipeline).
- The [Project Vulnerability report](../../user/application_security/vulnerability_report/index.md).
- The [security dashboard](../../user/application_security/security_dashboard/index.md).

## `artifacts:reports:dast` **(ULTIMATE)**

The `dast` report collects [DAST vulnerabilities](../../user/application_security/dast/index.md). The collected DAST
report uploads to GitLab as an artifact.

GitLab can display the results of one or more reports in:

- The merge request [security widget](../../user/application_security/dast/index.md#view-details-of-a-vulnerability-detected-by-dast).
- The pipeline [**Security** tab](../../user/application_security/security_dashboard/index.md#view-vulnerabilities-in-a-pipeline).
- The [Project Vulnerability report](../../user/application_security/vulnerability_report/index.md).
- The [security dashboard](../../user/application_security/security_dashboard/index.md).

## `artifacts:reports:dependency_scanning` **(ULTIMATE)**

The `dependency_scanning` report collects [Dependency Scanning vulnerabilities](../../user/application_security/dependency_scanning/index.md).
The collected Dependency Scanning report uploads to GitLab as an artifact.

GitLab can display the results of one or more reports in:

- The merge request [dependency scanning widget](../../user/application_security/dependency_scanning/index.md#overview).
- The pipeline [**Security** tab](../../user/application_security/security_dashboard/index.md#view-vulnerabilities-in-a-pipeline).
- The [security dashboard](../../user/application_security/security_dashboard/index.md).
- The [Project Vulnerability report](../../user/application_security/vulnerability_report/index.md).
- The [dependency list](../../user/application_security/dependency_list/).

## `artifacts:reports:dotenv`

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/17066) in GitLab 12.9.

The `dotenv` report collects a set of environment variables as artifacts.

The collected variables are registered as runtime-created variables of the job,
which you can use to [set dynamic environment URLs after a job finishes](../environments/index.md#set-dynamic-environment-urls-after-a-job-finishes).

If duplicate environment variables are present in a `dotenv` report:

- In GitLab 14.6 and later, the last one specified is used.
- In GitLab 14.5 and earlier, an error occurs.

The exceptions to the [original dotenv rules](https://github.com/motdotla/dotenv#rules) are:

- The variable key can contain only letters, digits, and underscores (`_`).
- The maximum size of the `.env` file is 5 KB.
  This limit [can be changed on self-managed instances](../../administration/instance_limits.md#limit-dotenv-file-size).
- On GitLab.com, [the maximum number of inherited variables](../../user/gitlab_com/index.md#gitlab-cicd)
  is 50 for Free, 100 for Premium and 150 for Ultimate. The default for
  self-managed instances is 150, and can be changed by changing the
  `dotenv_variables` [application limit](../../administration/instance_limits.md#limit-dotenv-variables).
- Variable substitution in the `.env` file is not supported.
- The `.env` file can't have empty lines or comments (starting with `#`).
- Key values in the `env` file cannot have spaces or newline characters (`\n`), including when using single or double quotes.
- Quote escaping during parsing (`key = 'value'` -> `{key: "value"}`) is not supported.

## `artifacts:reports:junit`

The `junit` report collects [JUnit report format XML files](https://www.ibm.com/docs/en/adfz/developer-for-zos/14.1.0?topic=formats-junit-xml-format).
The collected Unit test reports upload to GitLab as an artifact. Although JUnit was originally developed in Java, there
are many third-party ports for other languages such as JavaScript, Python, and Ruby.

See [Unit test reports](../unit_test_reports.md) for more details and examples.
Below is an example of collecting a JUnit report format XML file from Ruby's RSpec test tool:

```yaml
rspec:
  stage: test
  script:
    - bundle install
    - rspec --format RspecJunitFormatter --out rspec.xml
  artifacts:
    reports:
      junit: rspec.xml
```

GitLab can display the results of one or more reports in:

- The merge request [code quality widget](../../ci/unit_test_reports.md#how-it-works).
- The [full report](../../ci/unit_test_reports.md#viewing-unit-test-reports-on-gitlab).

Some JUnit tools export to multiple XML files. You can specify multiple test report paths in a single job to
concatenate them into a single file. Use either:

- A filename pattern (`junit: rspec-*.xml`).
- an array of filenames (`junit: [rspec-1.xml, rspec-2.xml, rspec-3.xml]`).
- A Combination of both (`junit: [rspec.xml, test-results/TEST-*.xml]`).

## `artifacts:reports:license_scanning` **(ULTIMATE)**

> Introduced in GitLab 12.8.

The License Compliance report collects [Licenses](../../user/compliance/license_compliance/index.md). The License
Compliance report uploads to GitLab as an artifact.

GitLab can display the results of one or more reports in:

- The merge request [license compliance widget](../../user/compliance/license_compliance/index.md).
- The [license list](../../user/compliance/license_compliance/index.md#license-list).

## `artifacts:reports:load_performance` **(PREMIUM)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/35260) in GitLab 13.2.
> - Requires GitLab Runner 11.5 and above.

The `load_performance` report collects [Load Performance Testing metrics](../../user/project/merge_requests/load_performance_testing.md).
The report is uploaded to GitLab as an artifact.

GitLab can display the results of only one report in the merge request
[load testing widget](../../user/project/merge_requests/load_performance_testing.md#how-load-performance-testing-works).

GitLab cannot display the combined results of multiple `load_performance` reports.

## `artifacts:reports:metrics` **(PREMIUM)**

The `metrics` report collects [Metrics](../metrics_reports.md). The collected Metrics report uploads to GitLab as an
artifact.

GitLab can display the results of one or more reports in the merge request
[metrics reports widget](../../ci/metrics_reports.md#metrics-reports).

## `artifacts:reports:requirements` **(ULTIMATE)**

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/2859) in GitLab 13.1.

The `requirements` report collects `requirements.json` files. The collected Requirements report uploads to GitLab as an
artifact and existing [requirements](../../user/project/requirements/index.md) are marked as Satisfied.

GitLab can display the results of one or more reports in the
[project requirements](../../user/project/requirements/index.md#view-a-requirement).

## `artifacts:reports:sast`

> - [Moved](https://gitlab.com/groups/gitlab-org/-/epics/2098) from GitLab Ultimate to GitLab Free in 13.3.

The `sast` report collects [SAST vulnerabilities](../../user/application_security/sast/index.md). The collected SAST
report uploads to GitLab as an artifact.

GitLab can display the results of one or more reports in:

- The merge request [SAST widget](../../user/application_security/sast/index.md#static-application-security-testing-sast).
- The [security dashboard](../../user/application_security/security_dashboard/index.md).

## `artifacts:reports:secret_detection`

> - Introduced in GitLab 13.1.
> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/222788) to GitLab Free in 13.3.
> - Requires GitLab Runner 11.5 and above.

The `secret-detection` report collects [detected secrets](../../user/application_security/secret_detection/index.md).
The collected Secret Detection report is uploaded to GitLab.

GitLab can display the results of one or more reports in:

- The merge request [secret scanning widget](../../user/application_security/secret_detection/index.md).
- The [pipeline **Security** tab](../../user/application_security/index.md#view-security-scan-information-in-the-pipeline-security-tab).
- The [security dashboard](../../user/application_security/security_dashboard/index.md).

## `artifacts:reports:terraform`

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/207528) in GitLab 13.0.
> - Requires [GitLab Runner](https://docs.gitlab.com/runner/) 11.5 and above.

The `terraform` report obtains a Terraform `tfplan.json` file. [JQ processing required to remove credentials](../../user/infrastructure/iac/mr_integration.md#configure-terraform-report-artifacts).
The collected Terraform plan report uploads to GitLab as an artifact.

GitLab can display the results of one or more reports in the merge request
[terraform widget](../../user/infrastructure/iac/mr_integration.md#output-terraform-plan-information-into-a-merge-request).

For more information, see [Output `terraform plan` information into a merge request](../../user/infrastructure/iac/mr_integration.md).