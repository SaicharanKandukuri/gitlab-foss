---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Install the GitLab Agent **(FREE)**

> [Moved](https://gitlab.com/groups/gitlab-org/-/epics/6290) from GitLab Premium to GitLab Free in 14.5.

To connect a cluster to GitLab, you need to install the GitLab Agent
onto your cluster.

## Prerequisites

- An existing Kubernetes cluster. If you don't have a cluster yet, you can create a new cluster on cloud providers, such as:
  - [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/docs/quickstart)
  - [Amazon Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
  - [Digital Ocean](https://docs.digitalocean.com/products/kubernetes/quickstart/)
- On self-managed GitLab instances, a GitLab administrator needs to set up the [GitLab Agent Server (KAS)](../../../../administration/clusters/kas.md).

## Installation steps

To install the GitLab Agent on your cluster:

1. [Define a configuration repository](#define-a-configuration-repository).
1. [Register the Agent with GitLab](#register-the-agent-with-gitlab).
1. [Install the Agent onto the cluster](#install-the-agent-onto-the-cluster).

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i> Watch a GitLab 14.2 [walking-through video](https://www.youtube.com/watch?v=XuBpKtsgGkE) with this process.

When you complete the installation process, you can
[view your Agent's status and activity information](#view-your-agents).
You can also [configure](#configure-the-agent) it to your needs.

### Define a configuration repository

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/259669) in GitLab 13.7, the Agent manifest configuration can be added to multiple directories (or subdirectories) of its repository.
> - Group authorization was [introduced](https://gitlab.com/groups/gitlab-org/-/epics/5784) in GitLab 14.3.

To create an Agent, you need a GitLab repository to hold its
configuration file. If you already have a repository holding your
cluster's manifest files, you can use it to store your
Agent's configuration file and sync them with no further steps.

#### Create the Agent's configuration file

To create an Agent, go to the repository where you want to store
it and add the Agent's configuration file under:

```plaintext
.gitlab/agents/<agent-name>/config.yaml
```

You **don't have to add any content** to this file at the moment you
create it. The fact that the file exists tells GitLab that this is
an Agent. You can edit it later to [configure the Agent](#configure-the-agent).

When creating this file, pay special attention to:

- The [Agent's naming format](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/identity_and_auth.md#agent-identity-and-name).
- The file extension: use the `.yaml` extension (`config.yaml`). The `.yml` extension is **not** recognized.

### Register the Agent with GitLab

> [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/5786) in GitLab 14.1, you can create a new Agent record directly from the GitLab UI.

Now that you've created your Agent's configuration file, register it
with GitLab.
When you register the Agent, GitLab generates a token that you need for
installing the Agent onto your cluster.

In GitLab, go to the project where you added your Agent's configuration
file and:

1. Ensure that [GitLab CI/CD is enabled in your project](../../../../ci/enable_or_disable_ci.md#enable-cicd-in-a-project).
1. From your project's sidebar, select **Infrastructure > Kubernetes clusters**.
1. Select **Actions**.
1. From the **Select an Agent** dropdown list, select the Agent you want to register and select **Register an Agent**.
1. GitLab generates a registration token for this Agent. Securely store this secret token, as you need it to install the Agent onto your cluster and to [update the Agent](#update-the-agent-version) to another version.
1. Copy the command under **Recommended installation method**. You need it to install the Agent onto your cluster through the one-liner installation method.

### Install the Agent onto the cluster

To connect your cluster to GitLab, install the registered Agent
onto your cluster. To install it, you can use either:

- [The one-liner installation method](#one-liner-installation).
- [The advanced installation method](#advanced-installation).

You can use the one-liner installation for trying to use the Agent for the first time, to do internal setups with
high trust, and to quickly get started. For long-term production usage, you may want to use the advanced installation
method to benefit from more configuration options.

#### One-liner installation

The one-liner installation is the simplest process, but you need
Docker installed locally. If you don't have it, you can either install
it or opt to the [advanced installation method](#advanced-installation).

To install the Agent on your cluster using the one-liner installation:

1. In your computer, open the terminal and connect to your cluster.
1. Run the command you copied when registering your cluster in the previous step.

Optionally, you can [customize the one-liner installation command](#customize-the-one-liner-installation).

##### Customize the one-liner installation

The one-liner command generated by GitLab:

- Creates a namespace for the deployment (`gitlab-kubernetes-agent`).
- Sets up a service account with `cluster-admin` rights (see [how to restrict this service account](#customize-the-permissions-for-the-agentk-service-account)).
- Creates a `Secret` resource for the Agent's registration token.
- Creates a `Deployment` resource for the `agentk` pod.

You can edit these parameters according to your needs to customize the
one-liner installation command at the command line. To find all available
options, run in your terminal:

```shell
docker run --pull=always --rm registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate --help
```

WARNING:
`--agent-version stable` can be used to refer to the latest stable
release at the time when the command runs. It's fine for testing
purposes but for production please make sure to specify a matching
version explicitly.

#### Advanced installation

For advanced installation options, use [the `kpt` installation method](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/tree/master/build/deployment/gitlab-agent).

##### Customize the permissions for the `agentk` service account

The GitLab Agent allows you to fully own your cluster and grant GitLab
the permissions you want. Still, to facilitate the process, by default the
generated manifests provide `cluster-admin` rights to the Agent.

You can restrict the Agent's access rights using Kustomize overlays. [An example is commented out](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/build/deployment/gitlab-agent/cluster/kustomization.yaml) in the `kpt` package you retrieved as part of the installation.

To create restricted permissions:

1. Copy the `cluster` directory.
1. Edit the `kustomization.yaml` and `components/*` files based on your requirements.
1. Run `kustomize build <your copied directory> | kubectl apply -f -` to apply your configuration.

The above setup allows you to regularly update from the upstream package using `kpt pkg update gitlab-agent --strategy resource-merge` and maintain your customizations at the same time.

## Configure the Agent

When successfully installed, you can [configure the Agent](../repository.md)
by editing its configuration file.
When you update the configuration file, GitLab transmits the
information to the cluster automatically without downtime.

## View your Agents

If you have at least the Developer role, you can access the Agent's
configuration repository and view the Agent's list:

1. On the left sidebar, select **Infrastructure > Kubernetes clusters**.
1. Select **Agent** tab to view clusters connected to GitLab through the Agent.

On this page, you can view:

- All the registered Agents for the current project.
- The connection status.
- The path to each Agent's configuration file.

Furthermore, if you select one of the Agents on your list, you can view its
[activity information](#view-the-agents-activity-information).

### View the Agent's activity information

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/277323) in GitLab 14.6.

The activity logs help you to identify problems and get the information
you need for troubleshooting. You can see events from a week before the
current date. To access an Agent's activity:

1. In your Agent's repository, go to the Agents list as described [above](#view-your-agents).
1. Select the Agent you want to see the activity.

The activity list includes:

- Agent registration events: when a new token is **created**.
- Connection events: when an Agent is successfully **connected** to a cluster.

Note that the connection status is logged when you connect an Agent for
the first time or after more than an hour of inactivity.

To check what else is planned for the Agent's UI and provide feedback,
see the [related epic](https://gitlab.com/groups/gitlab-org/-/epics/4739).

### View vulnerabilities in cluster images **(ULTIMATE)**

> [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/6346) in GitLab 14.8 [with a flag](../../../../administration/feature_flags.md) named `cluster_vulnerabilities`. Disabled by default.

Users with at least the [Developer role](../../../permissions.md)
can view cluster vulnerabilities. You can access them through the [vulnerability report](../../../application_security/vulnerabilities/index.md)
or in your cluster's image through the following process:

1. Configure [cluster image scanning](../../../application_security/cluster_image_scanning/index.md)
   to your build process.
1. Go to your Agent's configuration repository.
1. On the left sidebar, select **Infrastructure > Kubernetes clusters**.
1. Select the **Agent** tab.
1. Select the Agent you want to see the vulnerabilities for.

![Cluster Agent security tab UI](../../img/cluster_agent_security_tab_v14_8.png)

## Create multiple Agents

You can create and install multiple Agents using the same process
documented above. Give each Agent's configuration file a unique name
and you're good to go. You can create multiple Agents, for example:

- To reach your cluster from different projects.
- To connect multiple clusters to GitLab.

## Update the Agent version

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/340882) in GitLab 14.8, GitLab warns you on the Agent's list page to update the Agent version installed on your cluster.

To update the Agent's version on your cluster, you need to re-run the [installation command](#install-the-agent-onto-the-cluster)
with a newer `--agent-version`. Make sure to specify the other required parameters: `--kas-address`, `--namespace`, and `--agent-token`.
You can find the available `agentk` versions in [the container registry](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/container_registry/1223205?sort=desc).

If you don't have access to your Agent's token, you can retrieve it from your cluster:

1. On your computer, open the terminal and connect to your cluster.
1. To retrieve the namespace, run:

    ```shell
    kubectl get namespaces
    ```

1. To retrieve the secret, run:

    ```shell
    kubectl -n <namespace> get secrets
    ```

1. To retrieve the token, run:

    ```shell
    kubectl -n <namespace> get secret <secret-name> --template={{.data.token}} | base64 --decode
    ```

## Example projects

The following example projects can help you get started with the Agent.

- [Configuration repository](https://gitlab.com/gitlab-org/configure/examples/kubernetes-agent)
- This basic GitOps example deploys NGINX: [Manifest repository](https://gitlab.com/gitlab-org/configure/examples/gitops-project)

## Upgrades and version compatibility

The Agent is comprised of two major components: `agentk` and `kas`.
As we provide `kas` installers built into the various GitLab installation methods, the required `kas` version corresponds to the GitLab `major.minor` (X.Y) versions.

At the same time, `agentk` and `kas` can differ by 1 minor version in either direction. For example,
`agentk` 14.4 supports `kas` 14.3, 14.4, and 14.5 (regardless of the patch).

A feature introduced in a given GitLab minor version might work with other `agentk` or `kas` versions.
To make sure that it works, use at least the same `agentk` and `kas` minor version. For example,
if your GitLab version is 14.2, use at least `agentk` 14.2 and `kas` 14.2.

We recommend upgrading your `kas` installations together with GitLab instances' upgrades, and to
[upgrade the `agentk` installations](#update-the-agent-version) after upgrading GitLab.

The available `agentk` and `kas` versions can be found in
[the container registry](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/container_registry/).
