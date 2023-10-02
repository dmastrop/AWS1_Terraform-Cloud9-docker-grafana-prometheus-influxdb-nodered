output "volume_output" {
    value = docker_volume.container_volume[*].name
    # note that this is the docker_volume.container_volume.name
    # where name is  name = "${var.volume_name}-${count.index}" as defined in container/volume/main.tf
    # volume_name is from container/main.tf and is defined as 
    # volume_name = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
    # So basically the long string above with the volume count index appeneded to the end.
}