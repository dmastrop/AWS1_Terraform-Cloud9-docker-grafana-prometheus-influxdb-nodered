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
  # this is per the nodered documentation. See above notes in the null_resource
  #  host_path = "//home/ubuntu/environment/course7_terraform_docker/noderedvol"
  # this is the fully qualified path to the volume in my workspace
    
  # we need to make this host_path dynamic in case the directory of this noderedvol changes.
  # we can use a join functino but string interpolation would be better.  This is required to insert the path.cwd into the host_path
  # https://developer.hashicorp.com/terraform/language/expressions/references
  # https://developer.hashicorp.com/terraform/language/expressions/strings
  # https://developer.hashicorp.com/terraform/language/expressions/strings#interpolation
  host_path = var.host_path_in
  }
}  