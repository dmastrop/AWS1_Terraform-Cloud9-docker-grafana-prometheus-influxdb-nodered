### moved all of the variables code from main.tf to variables.tf

## variables definitions
## https://developer.hashicorp.com/terraform/language/values/variables

## validation rules for variables:
## https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules
## https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation
variable "ext_port" {
# the name is up to you
  type = number
  
  # as a test comment out the default and put ext_port = 1880 in terraform.tfvars so that it does not get published to the githhub commit and repo.
  #default = 1880
  
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