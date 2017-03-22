# Terraform Components

Terraform (https://terraform.io) allows you to define cloud based infrastructure.

By itself it can manage a large project as a single TF project. However, I prefer to use a tiered apparoach where I start at the top (VPC) and then work my way down the stack making mini-TF projects along the way that use the TF data state provider to access outputs from the tier above.

Also, from the outset we build everything "green/blue" (ie two enviroment sets that we can cross release via, Google green/blue deployments for further details). To make managing multiple green and blue enviroments we use TF modules, common system components and symlinks.


The components are built out in this order:-

1. VPC


