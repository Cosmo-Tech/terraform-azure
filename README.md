![Static Badge](https://img.shields.io/badge/Cosmo%20Tech-%23FFB039?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/Azure-%230078D4?style=for-the-badge)

#  Kubernetes cluster

## Requirements
* working Azure subscription and tenant (with admin access)
* [azure-cli](https://learn.microsoft.com/en/cli/azure/install-azure-cli?view=azure-cli-latest)
* [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    > If using Windows, Terraform must be accessible from PATH

## How to
* configure azure-cli
    * `az login`
    * select the subscription
    * `az account show`
* clone current repo
    ```
    git clone https://github.com/Cosmo-Tech/terraform-azure.git --branch <tag>
    cd terraform-azure
    ```
* deploy
    * fill `terraform-cluster/terraform.tfvars` variables according to your needs
    * run pre-configured script
        > :information_source: comment/uncomment the `terraform apply` line at the end to get a plan without deploy anything
        * Linux
            ```
            ./_run-terraform.sh
            ```
        * Windows
            ```
            ./_run-terraform.ps1
            ```

## Known errors
* Error: Get "http://localhost/api/v1/persistentvolumes/pv-name": dial tcp 127.0.0.1:80: connect: connection refused
    > If the cluster has been deleted, check the state file has also been deleted. If not, delete it.

## Developpers
* modules
    * **terraform-state-storage**
        * standalone module intended to facilitate creation of a Storage Account (that will be used to store states of others modules)
        * state of this module itselft will not be saved, once created it should never be changed
        * manually create a Storage Account called `cosmotechstates` will have the same effect
    * **terraform-cluster**
        * *cluster* = Kubernetes cluster
        * *dns* = pre-configure DNS zones that will be required in next deployments
        * *network* = network management
        * *nodes* = Kubernetes cluster nodes
        * *rbac* = access management
        * *storage* = persistent storage for Kubernetes statefulsets (this module is not used directly here, it's always used in remote modules through its Github URL)

<br>
<br>
<br>

Made with :heart: by Cosmo Tech DevOps team