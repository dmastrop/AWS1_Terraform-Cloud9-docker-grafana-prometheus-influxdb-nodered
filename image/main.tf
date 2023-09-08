# https://registry.terraform.io/providers/kreuzwerker/docker/2.15.0/docs/resources/image
resource "docker_image" "nodered_image" {
  # name of the image itself. This is the docker hub name reference not an arbitrary name that we are assigning.
  ## name = "nodered/node-red:latest"
  
  # add new code for separate environments dev and prod. see varaibles.tf file. We have var.env and var.image
  # https://developer.hashicorp.com/terraform/language/functions/lookup
  # the first is the value and the second is the key into the apped variable var.image.  var.env=dev will key into image:latest
  # and var.env=prod will key into image:latest-minimal
  # NOTE: we do not need {} around var.image because that is already a map with the {} in the variable definition (see variables.tf)
  ## name = lookup(var.image, var.env)
  
  # replacing var.env with terraform.workspace for environment accessment
  ## name = lookup(var.image, terraform.workspace)
  
  # optimize this (above) by getting rid of the lookup function and referencing the var.image directly through terraform.workspace
  # This optimization done throughout main.tf and variables.tf including for the locals in the variables.tf for the container_count
  # The syntax below will rerference the proper map entry in var.image based on the workspace (environment)
  # name = var.image[terraform.workspace]
  
  # for image main.tf initally run directly from the image
  name = "nodered/node-red:latest"
}