# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::CiConfiguration::ContainerScanningBuildAction do
  subject(:result) { described_class.new(auto_devops_enabled, gitlab_ci_content).generate }

  let(:params) { {} }

  context 'with existing .gitlab-ci.yml' do
    let(:auto_devops_enabled) { false }

    context 'container_scanning has not been included' do
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Dependency Scanning customization: https://docs.gitlab.com/ee/user/application_security/dependency_scanning/#customizing-the-dependency-scanning-settings
          # Container Scanning customization: https://docs.gitlab.com/ee/user/application_security/container_scanning/#customizing-the-container-scanning-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#cicd-variable-precedence

          # container_scanning:
          #   variables:
          #     DOCKER_IMAGE: ...
          #     DOCKER_USER: ...
          #     DOCKER_PASSWORD: ...
          stages:
          - test
          - security
          variables:
            RANDOM: make sure this persists
          include:
          - template: existing.yml
          - template: Security/Container-Scanning.gitlab-ci.yml
        CI_YML
      end

      context 'template includes are an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test security),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => [{ "template" => "existing.yml" }] }
        end

        it 'generates the correct YML' do
          expect(result[:action]).to eq('update')
          expect(result[:content]).to eq(expected_yml)
        end
      end

      context 'template include is not an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test security),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => { "template" => "existing.yml" } }
        end

        it 'generates the correct YML' do
          expect(result[:action]).to eq('update')
          expect(result[:content]).to eq(expected_yml)
        end
      end
    end

    context 'container_scanning has been included' do
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Dependency Scanning customization: https://docs.gitlab.com/ee/user/application_security/dependency_scanning/#customizing-the-dependency-scanning-settings
          # Container Scanning customization: https://docs.gitlab.com/ee/user/application_security/container_scanning/#customizing-the-container-scanning-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#cicd-variable-precedence

          # container_scanning:
          #   variables:
          #     DOCKER_IMAGE: ...
          #     DOCKER_USER: ...
          #     DOCKER_PASSWORD: ...
          stages:
          - test
          variables:
            RANDOM: make sure this persists
          include:
          - template: Security/Container-Scanning.gitlab-ci.yml
        CI_YML
      end

      context 'container_scanning template include are an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => [{ "template" => "Security/Container-Scanning.gitlab-ci.yml" }] }
        end

        it 'generates the correct YML' do
          expect(result[:action]).to eq('update')
          expect(result[:content]).to eq(expected_yml)
        end
      end

      context 'container_scanning template include is not an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => { "template" => "Security/Container-Scanning.gitlab-ci.yml" } }
        end

        it 'generates the correct YML' do
          expect(result[:action]).to eq('update')
          expect(result[:content]).to eq(expected_yml)
        end
      end
    end
  end

  context 'with no .gitlab-ci.yml' do
    let(:gitlab_ci_content) { nil }

    context 'autodevops disabled' do
      let(:auto_devops_enabled) { false }
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Dependency Scanning customization: https://docs.gitlab.com/ee/user/application_security/dependency_scanning/#customizing-the-dependency-scanning-settings
          # Container Scanning customization: https://docs.gitlab.com/ee/user/application_security/container_scanning/#customizing-the-container-scanning-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#cicd-variable-precedence

          # container_scanning:
          #   variables:
          #     DOCKER_IMAGE: ...
          #     DOCKER_USER: ...
          #     DOCKER_PASSWORD: ...
          include:
          - template: Security/Container-Scanning.gitlab-ci.yml
        CI_YML
      end

      it 'generates the correct YML' do
        expect(result[:action]).to eq('create')
        expect(result[:content]).to eq(expected_yml)
      end
    end

    context 'with autodevops enabled' do
      let(:auto_devops_enabled) { true }
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Dependency Scanning customization: https://docs.gitlab.com/ee/user/application_security/dependency_scanning/#customizing-the-dependency-scanning-settings
          # Container Scanning customization: https://docs.gitlab.com/ee/user/application_security/container_scanning/#customizing-the-container-scanning-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#cicd-variable-precedence

          # container_scanning:
          #   variables:
          #     DOCKER_IMAGE: ...
          #     DOCKER_USER: ...
          #     DOCKER_PASSWORD: ...
          include:
          - template: Auto-DevOps.gitlab-ci.yml
        CI_YML
      end

      before do
        allow_next_instance_of(described_class) do |secret_detection_build_actions|
          allow(secret_detection_build_actions).to receive(:auto_devops_stages).and_return(fast_auto_devops_stages)
        end
      end

      it 'generates the correct YML' do
        expect(result[:action]).to eq('create')
        expect(result[:content]).to eq(expected_yml)
      end
    end
  end

  # stubbing this method allows this spec file to use fast_spec_helper
  def fast_auto_devops_stages
    auto_devops_template = YAML.safe_load( File.read('lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml') )
    auto_devops_template['stages']
  end
end
