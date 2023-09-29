## STAGE 3 random_string container/main.tf:
# The current problem with where it is at right now is that if running multiple instances of an application they will all 
# use the same random string since the random string is in root/main.tf and not in the container/main.tf where each docker 
# instance will be created.  The STAGE 2 random_string block above needs to be commented out in root/main.tf and added into the 
# container/main.tf
# Each application type currently will use the same random string even if we are creating multiple instances of each.   
# Moving this to containers/main.tf will resolve this issue


# use random resource to generate unique names for the multi-container deployment
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  #count = 2
  # add count to get the 2 random_string resources rather than adding them one by one.
  #count = var.container_count
  
  # comment out the above. We need to convert the var.container_count to a local (see varaibles.tf) so that we can do a function call
  # on the count to align to the number of ext_port specificed in the terraform.tfvars file.
  # same needs to be done in the docker_container resource below.
  # STAGE2 get rid of this:
  #count = local.container_count
  
  # As part of STAGE 3 of container module add back in the count logic so that we can generate a 
  # unique random_string per instance of per application (key; for example nodered and infusedb)
  count = var.count_in
  
  
  
  #for_each = local.deployment
  
  # STAGE2 this will ensure that number of random strings will coincide with number of containers
  # STAGE 3. This for_each can no longer be used with count_in. They are mutually exclusive and this will generate
  # a terraform validate syntax error.  The number of random_strings will be generated in accordance with
  # the var.count_in which is calculated in the root/main.tf and passed into this module.
  # The calculation in root/main.tf is count_in = each.value.container_count
  # with the container_count defined in the locals of root/main.tf based upon the number of external ports
  # defined for the application in the terraform.tfvars file of the root.
  
  
  
  length = 4
  special = false
  upper = false
}









# deployment of the container based upon the image  "nodered_image" above
# "docker_container" must be used. That cannot be changed.
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nestedblock--ports
#resource "docker_container" "nodered_container" {
resource "docker_container" "app_container" {
  
  ##depends_on = [null_resource.docker_volume]
  ## keep depends_on in the root/main.tf

  
  ## this is not required in the container/main.tf (here)
  ## count will be kept in the root/main.tf
  ## count = local.container_count
  
  # As part of STAGE 3 of the module container, add back in the count logic
  # count_in is fully defined in the root/main.tf based upon container_count in the 
  # locals of root/main.tf
  count = var.count_in
  
  
  
  
  
  ## create a var.name_in because the name is imported in from root/maintf
  ## in root/main.tf this name is "name_in"
  #name = var.name_in
  
  # For STAGE 3 of the container module this name = name_in is no longer sufficient
  # name_in is just each.key of root/main.tf or "nodered" and "infusedb"
  # Add back the original logic that was in root/main.tf
  # The original code from root/main.tf is:
  # name_in = join("-", [each.key, terraform.workspace, random_string.random[each.key].result])
  # each.key is not accessible in container/main.tf. 
  
  # we are using count now so we cannot access each.key in this container/main.tf
  # note the replacements of each.key in the code above with var.name_in and count.index
  # This will provide unique names across all instances for each application (key, or var.name_in)
  name = join("-", [var.name_in, terraform.workspace, random_string.random[count.index].result])
  



 
  ##image = module.image.image_out
  ## for the container module this image can be received from the root/main.tf
  ## Convert this to a variable which needs to be added to the variables.tf file
  ## this is var.image_in because that what is specified in root/main.tf
  image = var.image_in
  
  ## for ports the container module can be received from root/main.tf
  ## Use var.int_port_in and var.ext_port_in from the naming in root/main.tf
  ports {
    internal = var.int_port_in
    
    #external = var.ext_port_in
    # As part of STAGE 3 of the container module add the count.index to the external port definition above
    external = var.ext_port_in[count.index]
  }
  
  
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nested-schema-for-volumes
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume
  volumes {
    container_path = var.container_path_in
    # var.conltainer_path_in is from root/main.tf and is "/data" for "nodered" for example
    # it will be different for infusedb application, etc....
  
  
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
    #volume_name = docker_volume.container_volume.name
    # As part of STAGE 3 incorporate the count.index to the volumne name as well
    volume_name = docker_volume.container_volume[count.index].name
    # This .name is defined below in the docker_volume resource
  
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

  # As part of STAGE 3 of the module container, add back in the count logic
  # See above. This has been added to the resource docker_container and the docker_volume and the 
  # random_string.
  count = var.count_in
  
  ##name = "${docker_container.nodered_container.name}-volume"
  # This above create a cycle dependency problem with the volume_name above
  # We can't create the container without the volume name and we cannot create the volume
  # without the container name.   This syntax will not work.
  # thus we need to remove this and use this:
  
  #name = "${var.name_in}-volume"
  # For STAGE 3 of container module add in the random string with the count.index to ensure that 
  # the volume name is unique per instance per applcation type (key or var.name_in)
 # name = "${var.name_in}-${random_string.random[count.index].result}-volume"
  
  # I have added the workspace as well to the volume
  name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"


  
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