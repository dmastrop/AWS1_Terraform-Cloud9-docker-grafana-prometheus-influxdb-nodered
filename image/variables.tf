# this bridges the "image_in" in root main.tf to the "image_in" in 
# image main.tf file
variable image_in {
    description = "name of image importing from root main.tf into image main.tf"
}