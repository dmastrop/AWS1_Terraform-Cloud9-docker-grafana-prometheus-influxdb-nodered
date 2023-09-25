# deployment of the container based upon the image  "nodered_image" above
# "docker_container" must be used. That cannot be changed.
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nestedblock--ports
resource "docker_container" "nodered_container" {
  
  ##depends_on = [null_resource.docker_volume]
  ## keep depends_on in the root/main.tf

  
  ## this is not required in the container/main.tf (here)
  ## count will be kept in the root/main.tf
  ## count = local.container_count
  
  ## create a var.name_in because the name is imported in from root/maintf
  ## in root/main.tf this name is "name_in"
  name = var.name_in
  
 
  ##image = module.image.image_out
  ## for the container module this image can be received from the root/main.tf
  ## Convert this to a variable which needs to be added to the variables.tf file
  ## this is var.image_in because that what is specified in root/main.tf
  image = var.image_in
  
  ## for ports the container module can be received from root/main.tf
  ## Use var.int_port_in and var.ext_port_in from the naming in root/main.tf
  ports {
    internal = var.int_port_in
    external = var.ext_port_in
  }
  
  
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nested-schema-for-volumes
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume
  volumes {
  container_path = var.container_path_in
  # var.conltainer_path_in is from root/main.tf and is "/data"
  
  
  # this is per the nodered documentation. See above notes in the null_resource
  #  host_path = "//home/ubuntu/environment/course7_terraform_docker/noderedvol"
  # this is the fully qualified path to the volume in my workspace
    
  # we need to make this host_path dynamic in case the directory of this noderedvol changes.
  # we can use a join functino but string interpolation would be better.  This is required to insert the path.cwd into the host_path
  # https://developer.hashicorp.com/terraform/language/expressions/references
  # https://developer.hashicorp.com/terraform/language/expressions/strings
  # https://developer.hashicorp.com/terraform/language/expressions/strings#interpolation
  
  # after getting rid of the null_resource local-exec provisioner in root/main.tf
  # we can use a better alternative for this below for the host_path
  #host_path = var.host_path_in
  
  #volume_name = "${var.name_in}-volume"
  # This will create discrete container volumes for each container based upon the container name
  # imported from root/main.tf name_in (join command)
  
  ## now that we create the resource "docker_volume" below we can simplify this volume_name above as
  ## this, avoiding the use of interpolation:
  volume_name = docker_volume.container_volume.name
  
  }
}  


resource "docker_volume" "container_volume" {
# create a resource for the docker volume. This will ensure that the volumes are
# added for each container and removed with each container during terraform destroy.

# note: creating a volume resource in the container/main.tf does fix the problem that occurred
# when using the null_resource local provisioner for the single "noderedvol".  This created resource
# conflicts with multiple containers because a singe volume was being used for all the containers.
# this no longer occurs with the volume resrouce.
# https://www.udemy.com/course/terraform-certified/learn/lecture/23431936#questions/20465070

  
  ##name = "${docker_container.nodered_container.name}-volume"
  # This above create a cycle dependency problem with the volume_name above
  # We can't create the container without the volume name and we cannot create the volume
  # without the container name.   This syntax will not work.
  # thus we need to remove this and use this:
  
  name = "${var.name_in}-volume"
  
  # to prevent the destruction of the volume with terraform destroy need to add lifecycle block below
  # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
  lifecycle {
    #prevent_destroy = true
    prevent_destroy = false
    # put this to false for now because it prevents any type of destruction
    # workaround it using the 
    # terraform destroy -target=module.container[0].docker_container.nodered_container
    # this is cumbersome but is very selective.
  }
}