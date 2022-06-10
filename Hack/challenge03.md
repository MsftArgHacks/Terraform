# Azure + GitHub + Terraform:

## Challenge 3 – Terraform: Infrastructure as Code - Part I

[Back](/Hack/challenge02.md) - [Home](README.md) - [Next](/Hack/challenge04.md)

### Introduction

Infrastructure as Code is the process of managing and provisioning computing infrastructure and its configuration through machine-processable definition files. It treats the infrastructure as a software system, applying software engineering practices to manage changes to the system in a repeatable, structured and safe way.

Infrastructure as Code characteristics:

- Declarative.
- Single source of truth.
- Increase repeatability and testability.
- Decrease provisioning time.
- Rely less on availability of persons to perform tasks.
- Use proven software development practices for deploying infrastructure.
- Repeatable and testable.
- Faster to provision.
- Idempotent provisioning and configuration (calls can be executed repeatedly while producing the same result).

With GitHub you can automate the process of deploying the Azure Services through Terraform scripts.

### What is Terraform?

Hashicorp Terraform is an open-source tool for provisioning and managing cloud infrastructure. It allows to define infrastructure as code in configuration files that describe the topology of cloud resources. These resources include virtual machines, storage accounts, and networking interfaces. The Terraform CLI provides a simple mechanism to deploy and version the configuration files to Azure.

Learn more in:

- [Terraform overview](https://docs.microsoft.com/es-es/azure/developer/terraform/overview)

### Terminology in Terraform.

## Provider

Terraform relies on plugins called **providers** to interact with cloud providers, SaaS providers, and other APIs.
The provider block configures the specified provider, in this case azurerm. A provider is a plugin that Terraform uses to create and manage your resources. You can define multiple provider blocks in a Terraform configuration to manage resources from different providers.

Learn more in:

- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform provider](https://www.terraform.io/docs/language/providers/index.html)

## Resource

Resources are the most important element in the Terraform language. Each resource block describes one or more infrastructure objects, such as virtual networks, compute instances, or higher-level components such as DNS records.

![Image alt text](https://github.com/MsftArgHacks/Terraform/raw/main/Hack/Images/terraform1.PNG)

Resource blocks have two strings before the block: the resource type and the resource name. In this example, the resource type is azurerm_resource_group and the name is example.
Resource blocks contain arguments which you use to configure the resource. The Azure provider documentation documents supported resources and their configuration options, including azurerm_resource_group and its supported arguments.

- Learn more in:
  [Terraform Resource](https://www.terraform.io/docs/language/resources/index.html)

## Variables

Terraform supports a few different variable formats. Depending on the usage, the variables are generally divided into inputs and outputs.

Input Variables serve as parameters for a Terraform module, so users can customize behavior without editing the source.
The input variables are used to define values that configure your infrastructure. These values can be used again and again without having to remember their every occurrence in the event it needs to be updated.

Input Variables examples:

```
variable "image_id" {
  type = string
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}
```

Output variables, in contrast, are used to get information about the infrastructure after deployment. These can be useful for passing on information such as IP addresses for connecting to the server.
Output Values are like return values for a Terraform module.

Output Varibles examples:

```
output "instance_ip_addr" {
  value = azure_instance.server.private_ip
}
```

Additionally, Local Values are a convenience feature for assigning a short name to an expression.

Local Variables examples:

```
locals {
  service_name = "forum"
  owner        = "Community Team"
}

```

Variables can be provided:

- Within the Terraform template
- Within its own Terraform template file
- Within a .TFVARS files
- Through command-line
- Through Environment variables

Learn more in:
[Terraform Variable ](https://www.terraform.io/docs/language/values/index.html)

## State, Remote State and Backends

Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.
This state is stored by default in a local file named **terraform.tfstate**, but it can also be stored remotely, which works better in a team environment.

With remote state, Terraform writes the state data to a remote data store, which can then be shared between all members of a team. Terraform supports storing state in **Azure Blob Storage**.
Remote state is implemented by a backend, which you can configure in your configuration's root module

Backends determine where state is stored. For example, the local (default) backend stores state in a local JSON file on disk.
When using a non-local backend, Terraform will not persist the state anywhere on disk except in the case of a non-recoverable error where writing the state to the backend failed

- Learn more in:
- [Terraform State](https://www.terraform.io/docs/language/state/index.html)
- [Terraform Backends](https://www.terraform.io/docs/language/state/backends.html)
- [Terraform Azurerm Backends](https://www.terraform.io/docs/language/settings/backends/azurerm.html)

## How Install Terraform in your workstation

- [Terraform Installation](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)

## Terraform Root Module

Terraform always runs in the context of a single **root module**. A complete Terraform configuration consists of a root module and the tree of **child modules** (which includes the modules called by the root module, any modules called by those modules, etc.).

![Image alt text](https://github.com/MsftArgHacks/Terraform/raw/main/Hack/Images/rootdictoryandmodules.PNG)

### Challenge

## Begin programming

1. Share your knowledge with your team about Terraform, Terraform variables, Terraform State, and Terraform Backend.
2. Where the terraform.tfstate should be located? and Why?.
3. Design an initial structure of the terraform files. It could contain a folder called Solution, inside a sub-folder called Modules.

### Success Criteria

1. You should have a folder structure created in Azure Repo for the root module and sub-folder modules for each component in the diagram.
2. The root module should contain at least a main.tf, variables.tf and output.tf files.
3. You should have created the Storage Account to host a terraform.tfstate.

### Parcial Solution

---

> [Here](CH03-root-parcialsolution.md) (Only use if it needed)

---

[Back](/Hack/challenge02.md) - [Home](README.md) - [Next](/Hack/challenge04.md)
