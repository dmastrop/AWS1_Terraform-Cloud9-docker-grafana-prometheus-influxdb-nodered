### moved all of the variables code from main.tf to variables.tf

## variables definitions
## https://developer.hashicorp.com/terraform/language/values/variables

## validation rules for variables:
## https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules
## https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation



# this is the environment varaible, i.e. production (prod) vs. development (dev)
variable "env" {
  type = string
  description = "The environment to deploy to"
  default = "dev"
  # if the env is not specified we definitely do not want to deploy to prod. Put default at dev.
}



variable "image" {
  # need to set up a map for the image for both dev and prod
  type = map
  description = "image for the container based upon deployment env"
  default = {
    dev = "nodered/node-red:latest"
    # this is the latest most fully featured nodered image for development. Has latest features
    prod = "nodered/node-red:latest-minimal"
    # minimal will be the tag of this production image with less features and less of attack security surface
  }
}




variable "ext_port" {
# the name is up to you
  #type = number
  
  ## type = list
  # change type to list now that terraform.tfvars is specifying the ext_port as a [list], [1880] to start.
  
  type = map
  # as we extend functionality, need to make the ext_port a map now so that we can have different external ports in different environments
  # See the terraform.tfvars for the values (dev is 1980, ..... and prod is 1880,.....)

  
  # flag this variable as senitive to hide values from terraform terminal display.
  # this is a test. This will also need to be done in the outputs.tf because that also displays this variable.
  # sensitive = true
  
  # as a test comment out the default and put ext_port = 1880 in terraform.tfvars so that it does not get published to the githhub commit and repo.
  #default = 1880
  # see terraform.tfvars for the value of this variable.
  
  # NOTE: see main.tf. I commented out the use of this variable in main.tf and let docker dynamically provision the ports IF
  # I need to use multiple containers.   This is because a static 1880 will conflict on the second container port binding to localhost
  # and only the first container will get created.
  # If count =1 we can use this varaible at 1880.
  
  
  # validation {
  #   condition = var.ext_port <= 65535 && var.ext_port > 0
  #   error_message = "The external port range must be in the valid port range 0 - 65535."
  # }
  
  


## temporarily comment this out again for the map testing with multiple environments....

#   validation {
#     condition = max(var.ext_port...) <= 65535 && min(var.ext_port...) > 0
#     error_message = "The external port range must be in the valid port range 0 - 65535."
#   }
#   # https://developer.hashicorp.com/terraform/language/expressions/function-calls#expanding-function-arguments
#   # https://developer.hashicorp.com/terraform/language/functions/max

 }





# variable "container_count" {
#   type = number
#   #default = 1
#   # change this to 3 for the multi-conatiner case with determinstic var.ext_port specified in terraform.tfvars.
#   default = 3
  
#   # to align this to the port count in terraform.tfvars list we can try
#   # default = length(var.ext_port) but function calls are not allowed on variables in terrafomr.
#   #default = length(var.ext_port)
  
#   #the solution is to create a local value (see below)
#   # https://developer.hashicorp.com/terraform/language/values/locals
  
# }

## comment out the above
## local value to replace the varaible "container_count" so that we can incorporate a function call and make this 
## locals container_count more extensible to the multiple ext_port multi-container scenario
# with locals we can align the number of external ports in terraform.tfvars to the count through this same "length" function call.
## https://developer.hashicorp.com/terraform/language/values/locals
locals {
  ## container_count = length(var.ext_port)
  # The count will be adjusted accordingly to how many ports are specified in the terraform.tfvars via the length(var.ext_port) function call.
  
  container_count = length(lookup(var.ext_port, var.env))
  # here we need to apply what we did for the resource docker_image in main.tf. Use the var.env as a key into the map var.ext_port
  # The lookup will apply the actual environment and get the count in that environment. So we can have different container_counts 
  # in different environments. For example if there are ports 1980, 1981, 1982 for env=dev and ports 1880, 1881 for env=prod
  # there will be 3 containers deployed if this is dev env and there will be 2 containers deployed if this is a prod env.
}









variable "internal_port" {
  type = number
  default = 1880
  #default = 1881
  
  validation {
    condition = var.internal_port == 1880
    error_message = "The internal port must be 1880."
  }
}