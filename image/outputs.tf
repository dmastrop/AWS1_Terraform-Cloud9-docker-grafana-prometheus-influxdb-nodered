output "image_out" {
   #value = docker_image.nodered_image.latest
    # the above is deprecated
    value = docker_image.nodered_image.image_id
    # we could export all attributes with
    # value = docker_image.nodered_image
}