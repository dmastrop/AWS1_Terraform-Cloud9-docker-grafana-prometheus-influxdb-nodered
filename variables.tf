### moved all of the variables code from main.tf to variables.tf

## variables definitions
## https://developer.hashicorp.com/terraform/language/values/variables

## validation rules for variables:
## https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules
## https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation
variable "ext_port" {
# the name is up to you
  type = number
  
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
  
  validation {
    condition = var.ext_port <= 65535 && var.ext_port > 0
    error_message = "The external port range must be in the valid port range 0 - 65535."
  }
}


variable "container_count" {
  type = number
  default = 1
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