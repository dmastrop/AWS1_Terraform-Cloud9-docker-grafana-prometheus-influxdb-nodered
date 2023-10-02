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
  
  
  
  
  
  # Convert this volumes block to a DYNAMIC BLOCK (step 4)
  # # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nested-schema-for-volumes
  # # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume
  # volumes {
  #   container_path = var.container_path_in
  #   # var.conltainer_path_in is from root/main.tf and is "/data" for "nodered" for example
  #   # it will be different for infusedb application, etc....
  
  
  #   # this is per the nodered documentation. See above notes in the null_resource
  #   #  host_path = "//home/ubuntu/environment/course7_terraform_docker/noderedvol"
  #   # this is the fully qualified path to the volume in my workspace
      
  #   # we need to make this host_path dynamic in case the directory of this noderedvol changes.
  #   # we can use a join functino but string interpolation would be better.  This is required to insert the path.cwd into the host_path
  #   # https://developer.hashicorp.com/terraform/language/expressions/references
  #   # https://developer.hashicorp.com/terraform/language/expressions/strings
  #   # https://developer.hashicorp.com/terraform/language/expressions/strings#interpolation
    
  #   # after getting rid of the null_resource local-exec provisioner in root/main.tf
  #   # we can use a better alternative for this below for the host_path
  #   #host_path = var.host_path_in
    
  #   #volume_name = "${var.name_in}-volume"
  #   # This will create discrete container volumes for each container based upon the container name
  #   # imported from root/main.tf name_in (join command)
    
  #   ## now that we create the resource "docker_volume" below we can simplify this volume_name above as
  #   ## this, avoiding the use of interpolation:
  #   #volume_name = docker_volume.container_volume.name
  #   # As part of STAGE 3 incorporate the count.index to the volumne name as well
  #   volume_name = docker_volume.container_volume[count.index].name
  #   # This .name is defined below in the docker_volume resource
  
  # }
  
  
  # Comment out the entire block above (volumes block) and convert this to a DYNAMIC BLOCK (step 4)
  dynamic "volumes" {
    for_each = var.volumes_in
    # this will do a for_each for the volumes listed in root/locals.tf and root/main.tf
    # for grafana this is the /var/lib/grafana and /etc/grafana
    content {
      #container_path = var.container_path_in
      container_path = volumes.value["container_path_each"]
      # these are the literal values of /var/lib/grafana and /etc/grafana
      
      #volume_name = docker_volume.container_volume[count.index].name
      ##volume_name = docker_volume.container_volume[volumes.key].name
      # we are no longer using count.index
      # volumes.key is the number of volumes in each key (grafana, prometheus, influxdb, nodered) as
      # in the root/locals.tf. For grafana this is [0] and [1] for the 2 container_path_each
      
      # With the addtion of the module volume we no longer have docker_volume in this file
      # So volume name above needs to be commented out and rewritten as call to the module.volume:
      # note we are using the count for the number of containers count_in (see above)
      volume_name = module.volume[count.index].volume_output[volumes.key]
      # this creates the unique volume name set per container by calling the module.volume that we just created
      # the volume_output is specified as the output in container/volume/outputs.tf file. This has the relevant
      # volume name for the container instance that this module is creating.
      # Note that the volumes.key as defined above will differentiate the multiple volumes per container.
      # for example for grafana there is /var/lib/grafana and then /etc/grafana
    }
  }
  
  
  
  
  # this next code is to create a containers.txt file with the container name: ip address: external port 
  # for all the containers in the terraform apply
  provisioner "local-exec" {
    #command = "echo ([for i in docker_container.app_container[*]: join(":", [i.self.name],i.ipv4_address,i.self.external)]) >> containers.txt"
    # the above will not work. Cannot reference the docker_container.app_container in a local provisioner
    # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nestedblock--ports
    # note that the self.ports is nested with the "external" per the link above
    # the for loop is required to index each external port as defined by the keys in the locals file root/locals.tf
    # the var.ext_port is keyed in and can have several ports per application (key) based on contents of terraform.tfvars
    
    #command = "echo ${self.name}: ${self.ip_address}:${join("", [for x in self.ports[*]["external"]: x])} >> containers.txt"
    # ip_address is deprecated. Requires network_data[0].ip_address
    command = "echo ${self.name}: ${self.network_data[0].ip_address}:${join("", [for x in self.ports[*]["external"]: x])} >> containers.txt"
    
    # add the terraform.workspace to the container.txt name so that each workspace creates different containers.txt file
    # command = "echo ${self.name}: ${self.network_data[0].ip_address}:${join("", [for x in self.ports[*]["external"]: x])} >> ${terraform.workspace}-containers.txt"
    # THIS CODE works great but the destroy provisioner below is not allowing terraform.workspace interoplation. See below.
    # So the entire file will be removed even if in one workspace and other is still active.
    
    
  }
  
  # this next provisioner is to delete the containers.txt file on terraform destroy
  provisioner"local-exec" {
    when = destroy
    command = "rm -f containers.txt"
    # add the code to selectively delete the workspace specific containers.txt file
   
    #command = "rm -f ${terraform-workspace}-containers.txt"
    # this code does not work. The error given is 
    # Destroy-time provisioners and their connection configurations may only reference attributes of the related resource, via 'self',
    # count.index', or 'each.key'.
    # References to other resources during the destroy phase can cause dependency cycles and interact poorly with create_before_destroy.
  }
}  







module "volume" {
  source  = "./volume"
  # note that the docker_volume is in /container/volume/main.tf
  count = var.count_in
  # recall that count_in in defined in root/main.tf and passed into the container/main.tf
  # count_in = each.value.container_count in root/main.tf. It is the number of containers for the key (application) in the map 
  # container_count = length(var.ext_port["grafana"][terraform.workspace])  in the root/locals.tf based on the key (application)
  # var.ext_port is defined in terraform.tfvars
  # count_in is also used on the docker_container resource above
  # We need it here because we need to create the length(var.volumes_in) per container
  # var.volumes_in is used in the container/volume/main.tf that his is calling.
  
  volume_count = length(var.volumes_in)
  # volume_count is the number of volumes that is required per container of this application
  
  volume_name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
  # this is the volume name in the original docker_volume resource
  # plus adding the random_string back in. (see the original docker_volume resource)

}










# ## MOVE this entire docker_volume block from container/main.tf to
# ## container/volume/main.tf. Then reference this docker_volume from this canatainer/main.tf
# ## so that we create the number of volumes per instance container created for the app.  
# ##  SEE ABOVE for the reference.

# resource "docker_volume" "container_volume" {
# # create a resource for the docker volume. This will ensure that the volumes are
# # added for each container and removed with each container during terraform destroy.

# # note: creating a volume resource in the container/main.tf does fix the problem that occurred
# # when using the null_resource local provisioner for the single "noderedvol".  This created resource
# # conflicts with multiple containers because a singe volume was being used for all the containers.
# # this no longer occurs with the volume resrouce.
# # https://www.udemy.com/course/terraform-certified/learn/lecture/23431936#questions/20465070

#   # As part of STAGE 3 of the module container, add back in the count logic
#   # See above. This has been added to the resource docker_container and the docker_volume and the 
#   # random_string.
  
#   #count = var.count_in
#   # DYNAMIC BLOCK (step 5). commment out the above
#   count = length(var.volumes_in)
#   # for grafana this is equal to 2 and uses index [0] and [1]
  
  
  
#   ##name = "${docker_container.nodered_container.name}-volume"
#   # This above create a cycle dependency problem with the volume_name above
#   # We can't create the container without the volume name and we cannot create the volume
#   # without the container name.   This syntax will not work.
#   # thus we need to remove this and use this:
  
#   #name = "${var.name_in}-volume"
#   # For STAGE 3 of container module add in the random string with the count.index to ensure that 
#   # the volume name is unique per instance per applcation type (key or var.name_in)
# # name = "${var.name_in}-${random_string.random[count.index].result}-volume"
  
#   # I have added the workspace as well to the volume
#   #name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
#   # DYNAMIC BLOCK (step 6). comment out the above
#   # for now just use the count.index as defined above based on the length(var.volumes_in)
#   name = "${var.name_in}-${terraform.workspace}-${count.index}-volume"
  




  
#   # to prevent the destruction of the volume with terraform destroy need to add lifecycle block below
#   # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
#   lifecycle {
#     #prevent_destroy = true
#     prevent_destroy = false
#     # put this to false for now because it prevents any type of destruction
#     # workaround it using the 
#     # terraform destroy -target=module.container[0].docker_container.nodered_container
#     # this is cumbersome but is very selective.
#   }
  
#   # add a local provisioner to store the volume in a backup directory so that on terraform destroy
#   # we still have a copy of the volume data. THe data will be stored in a backup folder
#   provisioner "local-exec" {
#     when = destroy
#     #command = "mkdir ${path.cwd}/../backup/"
#     command = "mkdir ${path.cwd}/../backup_workspace_1/"
#     # the backup directory will be created one level up from current working directory which
#     # will be in the root workspace directory /home/ubuntu/environment/course7_terraform_docker
#     # terraform console: path.cwd = "/home/ubuntu/environment/course7_terraform_docker"
#     # We do not want to store backups in the git committed code directory.
#     # NOTE: with multiple containers there is a problem. The local provisioner errors stating that the 
#     # folder already exists after the first container
#     # Need to add the on_failure continue 
#     # note that this just creates the backup folder. The backups of the volumes still needs to be done
#     on_failure = continue
#   }
  
#   # add a second provisioner to backup the actual volumes of all the containers.
#   # must use the self object. Provisioner blocks cannot refer to parent resource by name
#   # https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#the-self-object
#   # The parent resource here is docker_volume.container_volume
#   # We will use the self.name and self.mountpoint for the name and the mountpoint of each container volume that is
#   # being destroyed.  This will be stored in the backup directory as a tar file.
#   # the self.mountpoint is indicated in this document:
#   # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume#mountpoint
#   # both name and mountpoint are attributes of the docker_volume
#   # self.name refers to  name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
#   # self.mountpoint will be tarred and put in the folder of the volume of the same name
#   provisioner "local-exec" {
#     when = destroy
#     command = "sudo tar -czvf ${path.cwd}/../backup_workspace_1/${self.name}.tar.gz ${self.mountpoint}/"
#     #command = "sudo tar -czvf ${path.cwd}/../backup/${self.name}.tar.gz ${self.mountpoint}/"
#     on_failure = fail
#     # we want to know if this fails!!
#   }
  
# } # this is for the resource "docker_volume"