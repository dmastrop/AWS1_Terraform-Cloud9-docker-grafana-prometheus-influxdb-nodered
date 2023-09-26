output "image_out" {
   #value = docker_image.nodered_image.latest
    # the above is deprecated
    
    value = docker_image.nodered_image.image_id
    # we could export all attributes with
    # value = docker_image.nodered_image
    
    # edit the above to the following for the generic multiple images
    # from a single image module code.
    # see also image/main.tf
    value = docker_image.container_image.image_id
}