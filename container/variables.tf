## terraform does good type inference so don't need to list all the types here.
## order does not matter
variable "name_in" {
    type = string
}

variable "image_in" {
    
}

variable "int_port_in" {
    type = number    
}

variable "ext_port_in" {
    #type = number
    
}

# DYNAMIC BLOCK (step 7). Comment out this container_path_in
# We are using volumes_in instead (see below) with the dynamic block provisioning.
variable "container_path_in" {
    
}

# variable "host_path_in" {
    
# }
#   # Get rid of the host_path_in as part of the null_resource cleanup and conversion to using
#   # the docker volume resource in the container/main.tf
    # This is also removed in the root/main.tf

# As part of STAGE 3 of the container module incorporating the for_each with count, add this 
# count_in that is used in the root/main.tf
variable "count_in" {
    
}

# As part of DYNAMIC BLOCK (step 3) creation in root/locals.tf and root/main.tf we need to define the  
# importation of volumes into this container module as volumes_in
variable "volumes_in" {

}
