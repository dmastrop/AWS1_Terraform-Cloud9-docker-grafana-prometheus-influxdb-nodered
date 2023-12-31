# moved the entire docker_volume resource below from the container/main.tf
# to the container/volume/main.tf
# test update 12/30/23.


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
  
  #count = var.count_in
  # DYNAMIC BLOCK (step 5). commment out the above
  #count = length(var.volumes_in)
  # for grafana this is equal to 2 and uses index [0] and [1]
  
  # for this nesting of the volume module container/volume/main.tf
  # use the imported variable var.volume_count as defined in container/main.tf
  # and comment out the above count
  count = var.volume_count
  
  
  
  
  
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
  #name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
  # DYNAMIC BLOCK (step 6). comment out the above
  # for now just use the count.index as defined above based on the length(var.volumes_in)
  #name = "${var.name_in}-${terraform.workspace}-${count.index}-volume"
  
  # for this nesting of the volume module container/volume/main.tf
  # use the imported variable var.volume_name as defined in container/main.tf
  # and comment out the above name
  # append the count.index to differentiate the multiple volumes per application that may exist
  # this is the imported valume_name from container/main.tf
  # volume_name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
  name = "${var.volume_name}-${count.index}"
  



  
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
  
  # add a local provisioner to store the volume in a backup directory so that on terraform destroy
  # we still have a copy of the volume data. THe data will be stored in a backup folder
  provisioner "local-exec" {
    when = destroy
    #command = "mkdir ${path.cwd}/../backup/"
    
    # FOR AWS project workspace change the folder to backup_worksapce_2 so that it does not conflict with 
    # docker workspace project.
    # command = "mkdir ${path.cwd}/../backup_workspace_1/"
    command = "mkdir ${path.cwd}/../backup_workspace_2/"
    
    # the backup directory will be created one level up from current working directory which
    # will be in the root workspace directory /home/ubuntu/environment/course7_terraform_docker
    # terraform console: path.cwd = "/home/ubuntu/environment/course7_terraform_docker"
    # We do not want to store backups in the git committed code directory.
    # NOTE: with multiple containers there is a problem. The local provisioner errors stating that the 
    # folder already exists after the first container
    # Need to add the on_failure continue 
    # note that this just creates the backup folder. The backups of the volumes still needs to be done
    on_failure = continue
  }
  
  # add a second provisioner to backup the actual volumes of all the containers.
  # must use the self object. Provisioner blocks cannot refer to parent resource by name
  # https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#the-self-object
  # The parent resource here is docker_volume.container_volume
  # We will use the self.name and self.mountpoint for the name and the mountpoint of each container volume that is
  # being destroyed.  This will be stored in the backup directory as a tar file.
  # the self.mountpoint is indicated in this document:
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume#mountpoint
  # both name and mountpoint are attributes of the docker_volume
  # self.name refers to  name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
  # self.mountpoint will be tarred and put in the folder of the volume of the same name
  provisioner "local-exec" {
    when = destroy
    
    # FOR AWS project workspace change the folder to backup_worksapce_2 so that it does not conflict with 
    # docker workspace project.
    #command = "sudo tar -czvf ${path.cwd}/../backup_workspace_1/${self.name}.tar.gz ${self.mountpoint}/"
    command = "sudo tar -czvf ${path.cwd}/../backup_workspace_2/${self.name}.tar.gz ${self.mountpoint}/"
    #command = "sudo tar -czvf ${path.cwd}/../backup/${self.name}.tar.gz ${self.mountpoint}/"
    on_failure = fail
    # we want to know if this fails!!
  }
  
} # this is for the resource "docker_volume"