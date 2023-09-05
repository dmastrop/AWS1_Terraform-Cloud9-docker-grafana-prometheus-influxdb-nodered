terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      # this is the api for docker that we will use.
      #version = "2.12.0"
      #version = "2.15.0"
      # this is a test version and will be blocked by the .terraform.lock.hcl file.
      # my setup is currently at 
      # version = 3.0.2
      # to get the 2.15.0 to take must do a    terraform init -upgrade
      
      # to prevent an upgrade on second number do this:
      #  version = "~> 2.12.0"  this will allow any 2.12.x but not 2.15
      
      # version  = "~> 2.12" will allow 2.x but not 3.x.  Rightmost number can increase as much as possible without next left number incrementing.
      
      # version = "~> 2.15.0" will lock it to 2.15.x 
      version = "~> 2.15.0"
      
    }
  }
}

provider "docker" {}
# this instantiates the docker provider itself


resource "null_resource" "docker_volume" {
# https://developer.hashicorp.com/terraform/language/v1.1.x/resources/provisioners/local-exec
  provisioner "local-exec" {
    command = "mkdir noderedvol/ || true && sudo chown -R 1000:1000 noderedvol/"
    # note the nodered documentation: the volume must be mounted to docker container /data directory and the following::
     # https://nodered.org/docs/getting-started/docker
     # Using a Host Directory for Persistence (Bind Mount)
     # Note: "Users migrating from version 0.20 to 1.0 will need to ensure that any existing /data directory has the correct ownership. 
     # As of 1.0 this needs to be 1000:1000. 
     # This can be forced by the command sudo chown -R 1000:1000 path/to/your/node-red/data
     
     # the "|| true"logic makes this more idempotent, so that RC=0 is returned and even though it still fails to create the directory again, 
     # it will not error out and fail the terraform apply.
  }
}


# ### moved all of the variables code from main.tf to variables.tf (single hash # comment is the final code for this here)

# ## variables definitions
# ## https://developer.hashicorp.com/terraform/language/values/variables

# ## validation rules for variables:
# ## https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules
# ## https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation
# variable "ext_port" {
# # the name is up to you
#   type = number
#   default = 1880
  
#   validation {
#     condition = var.ext_port <= 65535 && var.ext_port > 0
#     error_message = "The external port range must be in the valid port range 0 - 65535."
#   }
# }


# variable "container_count" {
#   type = number
#   default = 1
# }


# variable "internal_port" {
#   type = number
#   default = 1880
#   #default = 1881
  
#   validation {
#     condition = var.internal_port == 1880
#     error_message = "The internal port must be 1880."
#   }
# }




# https://registry.terraform.io/providers/kreuzwerker/docker/2.15.0/docs/resources/image
resource "docker_image" "nodered_image" {
  # name of the image itself. This is the docker hub name reference not an arbitrary name that we are assigning.
  name = "nodered/node-red:latest"
}



# use random resource to generate unique names for the multi-container deployment
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  #count = 2
  # add count to get the 2 random_string resources rather than adding them one by one.
  #count = var.container_count
  
  # comment out the above. We need to convert the var.container_count to a local (see varaibles.tf) so that we can do a function call
  # on the count to align to the number of ext_port specificed in the terraform.tfvars file.
  # same needs to be done in the docker_container resource below.
  count = local.container_count
  
  length = 4
  special = false
  upper = false
}


## Comment out this for Count main.tf version2
# resource "random_string" "random2" {
#   length = 4
#   special = false
#   upper = false
# }




# deployment of the container based upon the image  "nodered_image" above
# "docker_container" must be used. That cannot be changed.
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nestedblock--ports
resource "docker_container" "nodered_container" {
  #count = 2
  # must add the count here as well. The count.index will be incremented with index [0] and [1] for the name defined below.
 # count = var.container_count
  
  # comment out the above. We need to convert the var.container_count to a local (see varaibles.tf) so that we can do a function call
  # on the count to align to the number of ext_port specificed in the terraform.tfvars file.
  # same needs to be done in the random_string resource above.
  count = local.container_count
  
  
  
  
  
  

  #name = "nodered"
  # this is a logical value for referencing only.
  # randomize the name:
  #name = join("-", ["nodered", random_string.random.result])
  # for multiple count: use random_string.random.result[count.index].result
  # For each random_string count above, this will increment the count.index value.  Note need to add the count = 2 in this resource as well (see above).
  # the index will start at [0] and then [1], etc.....
  # https://developer.hashicorp.com/terraform/language/meta-arguments/count
  name = join("-", ["nodered", random_string.random[count.index].result])
  
  image = docker_image.nodered_image.latest
  # this is referenced from the docker image above: docker_image.nodered_image.latest
  # "latest" can be referenced from other resources as a single image.  This seems to work only with docker 2.15.0
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image
  
  # for docker 3.0.2 use image_id. Minimum version to support this syntax is 2.21.0 so use version = "~> 2.21.0" in the 
  # docker provider block if want to use this syntax.   I am on 2.15.0 and this new syntax will not work (error)
  # https://stackoverflow.com/questions/73451024/where-to-find-information-about-the-following-terraform-provider-attribute-depre
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image#read-only
  # image = docker_image.nodered_image.image_id
  ##image = docker_image.nodered_image.image_id


  # ports will need to be exposed on this container
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nestedblock--ports
  # internal (Number) Port within the container.; external (Number) Port exposed out of the container. If not given a free random port >= 32768 will be used.
  # ip (String) IP address/mask that can access this port. Defaults to 0.0.0.0.; protocol (String) Protocol that can be used over this port. Defaults to tcp.
  ports {
    # ports is a nested schema
    
    
    #internal = 1880
    # terraform refers to this as a number and not an integer.  1880 is the nodered listening port.  See documentation
    internal = var.internal_port
    
    
    #external = 1880
    
    # if we comment out the external port, docker will automatically choose external port for you
    # for varaibles testing uncomment this out.  var.ext_port refers to the varaible specified above.
    #external = var.ext_port
    
    # start adding mutliple ports. First define ext_port as a list
    #external = var.ext_port[0]
    
    # Next add count.index to make this extensible for multiple containers. First container has index of 0, second has index of 1, and so on....
    external = var.ext_port[count.index]
  
    
    # NOTE:: with the var.ext_port provisioned at 1880 there is a problem with starting the second container. Comment this out so that
    # both external ports are dynamically provisioned by docker if using a count > 1.
    # For now we are using count =1 and this setting with var.ext_port is fine....
  }
  
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nested-schema-for-volumes
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume
  volumes {
    container_path = "/data"
    # this is per the nodered documentation. See above notes in the null_resource
    ## host_path = "//home/ubuntu/environment/course7_terraform_docker/noderedvol"
    # this is the fully qualified path to the volume in my workspace
    
    # we need to make this host_path dynamic in case the directory of this noderedvol changes.
    # we can use a join functino but string interpolation would be better.  This is required to insert the path.cwd into the host_path
    # https://developer.hashicorp.com/terraform/language/expressions/references
    # https://developer.hashicorp.com/terraform/language/expressions/strings
    # https://developer.hashicorp.com/terraform/language/expressions/strings#interpolation
    host_path = "${path.cwd}/noderedvol"
  }
  
}  







## this resource (below) was created because the terraform state got out of synch due to a test scenario.
## this is no longer needed.
## the reference documentation on this is https://developer.hashicorp.com/terraform/cli/import
## this resource must be created to do the import of the extraneous resources that are out of state
## FROM THE DOCUMENTATION
  # The terraform import CLI command can only import resources into the state. 
  # Importing via the CLI does not generate configuration. If you want to generate the accompanying configuration for imported resources, 
  # use the import block instead.
  # Before you run terraform import you must manually write a resource configuration block for the resource. 
  # The resource block describes where Terraform should map the imported object

# resource "docker_container" "nodered_container_import" {
#   name = "nodered-wo5o"
#   # this is the remaining container after the out of state condition following a delete. We need to import this container so that
#   # it can be properly deleted by terraform. To do this we have to import it into the terraform state
#   # https://developer.hashicorp.com/terraform/cli/import
#   # this is the docker ps of the remaining container:
#   # c0d5f11a3635   c18405a73444   "./entrypoint.sh"   45 minutes ago   Up 45 minutes (healthy)   0.0.0.0:32776->1880/tcp   nodered-wo5o
#   image = docker_image.nodered_image.latest
# }






## Comment this container out for Count main.tf version2
## second docker container
# resource "docker_container" "nodered_container-2" {
#   #name = "nodered-2"
#   # this is a logical value for referencing only.
#   # randomize the name:
#   name = join("-", ["nodered", random_string.random2.result])
  
  
#   image = docker_image.nodered_image.latest
#   # this is referenced from the docker image above: docker_image.nodered_image.latest
#   # "latest" can be referenced from other resources as a single image.  This seems to work only with docker 2.15.0
#   # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image
  
#   # for docker 3.0.2 use 
#   # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image#read-only
#   # image = docker_image.nodered_image.image_id
#   ##image = docker_image.nodered_image.image_id

#   # ports will need to be exposed on this container
#   # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container
#   # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nestedblock--ports
#   # internal (Number) Port within the container.; external (Number) Port exposed out of the container. If not given a free random port >= 32768 will be used.
#   # ip (String) IP address/mask that can access this port. Defaults to 0.0.0.0.; protocol (String) Protocol that can be used over this port. Defaults to tcp.
#   ports {
#     # ports is a nested schema
#     internal = 1880
#     # terraform refers to this as a number and not an integer.  1880 is the nodered listening port.  See documentation
#     #external = 1880
#     # if we comment out the external port, docker will automatically choose external port for you
#   }
# }  





### moved all of this output code from main.tf to outputs.tf (single hash # comment has the final code)

### Generate some ouputs
# https://developer.hashicorp.com/terraform/language/values/outputs

##output "IP_address" {
# outputs cannot contain spaces in name in newer versions
##  value = docker_container.nodered_container.ip_address
##  description = "the IP address of the nodered container"
##}

#output "Container_name" {
#  value = docker_container.nodered_container.name
#  description = "this is the name of the container"
#}

# ## Adding in Count in version2 of main.tf, but comment these out for now
# # what we need here is to index the resource docker_container.nodered_container by index, ie
# # resource docker_container.nodered_container[0] and resource docker_container.nodered_container[1]

# # output "Container_name1" {
# #   #value = docker_container.nodered_container.name
# #   value = docker_container.nodered_container[0].name
# #   description = "this is the name of the container"
# # }

# # output "Container_name2" {
# #   #value = docker_container.nodered_container-2.name
# #   value = docker_container.nodered_container[1].name
# #   description = "this is the name of the container-2"
# # }

# # replace the above 2 blocks for the name with a single block using the splat
# # https://developer.hashicorp.com/terraform/language/expressions/splat

# output "Container_names" {
#   #value = docker_container.nodered_container.name
#   value = docker_container.nodered_container[*].name
#   description = "this is the names of the containers"
# }




# # optimizing the ip address output is more difficult. A simple double splat like this below does not worK:
# # value = join(":", [docker_container.nodered_container[*].ip_address, docker_container.nodered_container[*].ports[0].external])
# # this flatten + splat will not work either. It will apply but the ip addreses will be listed and then the ports all : separated. Not a good format.
# # value = join(":", flatten([docker_container.nodered_container[*].ip_address, docker_container.nodered_container[*].ports[0].external]))
# # flatten reduced one level of nesting so that it could be applied but this will not work.
# # For loop (expression) is much better:  https://developer.hashicorp.com/terraform/language/expressions/for

# # output "IP_address_and_port_1" {
# # # outputs cannot contain spaces in name in newer versions
# #   #value = join(":", [docker_container.nodered_container.ip_address, docker_container.nodered_container.ports[0].external])
# #   value = join(":", [docker_container.nodered_container[0].ip_address, docker_container.nodered_container[0].ports[0].external])
# #   description = "the IP address and port of the nodered container"
# # }

# # output "IP_address_and_port_2" {
# # # outputs cannot contain spaces in name in newer versions
# #   #value = join(":", [docker_container.nodered_container-2.ip_address, docker_container.nodered_container-2.ports[0].external])
# #   value = join(":", [docker_container.nodered_container[1].ip_address, docker_container.nodered_container[1].ports[0].external])
# #   description = "the IP address and port of the nodered container"
# # }
 
# # use a "for" loop the optimize this code.
# # 
# output "IP_addresses_and_ports_pairs" {
# # outputs cannot contain spaces in name in newer versions

#   #value = join(":", [docker_container.nodered_container.ip_address, docker_container.nodered_container.ports[0].external])
#   #value = join(":", [docker_container.nodered_container[0].ip_address, docker_container.nodered_container[0].ports[0].external])
#   value = [for i in docker_container.nodered_container[*]: join(":", [i.ip_address],i.ports[*]["external"])]
#   # [for i in docker_container.nodered_container[*]: i]    this will dump everything. But we can grep attributes out with i.ip_address for example
#   # note that the i.ports[*] splat does not require brackets in the join because it returns a nested list with brackets
#   # if we were to use i.ports[0] this would require brackets in the join because it returns an un-nested list
#   # Thus alternate syntax: [for i in docker_container.nodered_container[*]: join(":", [i.ip_address], [i.ports[0]["external"]])]
  
#   description = "the IP address and external port of each nodered container"
# }