![Static Badge](https://img.shields.io/badge/Cosmo%20Tech-%23FFB039?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/Azure-%230078D4?style=for-the-badge)

#  Kubernetes cluster

## Requirements
* working Azure subscription and tenant (with admin access)
* Linux (Debian/Ubuntu) workstation with:
    * [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    * [az-cli](https://learn.microsoft.com/en/cli/azure/install-azure-cli?view=azure-cli-latest)
    * [jq](https://jqlang.org/)
    * [kubectl](https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/)

## How to
* configure azure cli
    * TODO

* clone current repo
    ```
    git clone https://github.com/Cosmo-Tech/terraform-azure.git
    cd terraform-azure
    ```
* deploy
    * fill `terraform-cluster/terraform.tfvars` variables according to your needs
    * run pre-configured script
        > :information_source: comment/uncomment the `terraform apply` line at the end to get a plan without deploy anything
        ```
        ./_run-terraform.sh
        ```
    * TODO

## Developpers
* modules
    * **terraform-state-storage**
        * TODO
    * **terraform-cluster**
        * TODO


<br>
<br>
<br>

Made with :heart: by Cosmo Tech DevOps team