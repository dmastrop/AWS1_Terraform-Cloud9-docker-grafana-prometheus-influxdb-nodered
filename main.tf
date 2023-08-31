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


# https://registry.terraform.io/providers/kreuzwerker/docker/2.15.0/docs/resources/image
resource "docker_image" "nodered_image" {
  # name of the image itself. This is the docker hub name reference not an arbitrary name that we are assigning.
  name = "nodered/node-red:latest"
}



# use random resource to generate unique names for the multi-container deployment
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length = 4
  special = false
  upper = false
}

resource "random_string" "random2" {
  length = 4
  special = false
  upper = false
}




# deployment of the container based upon the image  "nodered_image" above
# "docker_container" must be used. That cannot be changed.
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#nestedblock--ports
resource "docker_container" "nodered_container" {
  #name = "nodered"
  # this is a logical value for referencing only.
  # randomize the name:
  name = join("-", ["nodered", random_string.random.result])
  
  
  image = docker_image.nodered_image.latest
  # this is referenced from the docker image above: docker_image.nodered_image.latest
  # "latest" can be referenced from other resources as a single image.  This seems to work only with docker 2.15.0
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image
  
  # for docker 3.0.2 use 
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
    internal = 1880
    # terraform refers to this as a number and not an integer.  1880 is the nodered listening port.  See documentation
    #external = 1880
    # if we comment out the external port, docker will automatically choose external port for you
  }
}  

## second docker container
resource "docker_container" "nodered_container-2" {
  #name = "nodered-2"
  # this is a logical value for referencing only.
  # randomize the name:
  name = join("-", ["nodered", random_string.random2.result])
  
  
  image = docker_image.nodered_image.latest
  # this is referenced from the docker image above: docker_image.nodered_image.latest
  # "latest" can be referenced from other resources as a single image.  This seems to work only with docker 2.15.0
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image
  
  # for docker 3.0.2 use 
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
    internal = 1880
    # terraform refers to this as a number and not an integer.  1880 is the nodered listening port.  See documentation
    #external = 1880
    # if we comment out the external port, docker will automatically choose external port for you
  }
}  



### Generate some ouputs
# https://developer.hashicorp.com/terraform/language/values/outputs

output "IP_address" {
# outputs cannot contain spaces in name in newer versions
  value = docker_container.nodered_container.ip_address
  description = "the IP address of the nodered container"
}

#output "Container_name" {
#  value = docker_container.nodered_container.name
#  description = "this is the name of the container"
#}

output "Container_name1" {
  value = docker_container.nodered_container.name
  description = "this is the name of the container"
}

output "Container_name2" {
  value = docker_container.nodered_container-2.name
  description = "this is the name of the container-2"
}

output "IP_address_and_port_1" {
# outputs cannot contain spaces in name in newer versions
  value = join(":", [docker_container.nodered_container.ip_address, docker_container.nodered_container.ports[0].external])
  description = "the IP address and port of the nodered container"
}

output "IP_address_and_port_2" {
# outputs cannot contain spaces in name in newer versions
  value = join(":", [docker_container.nodered_container.ip_address, docker_container.nodered_container-2.ports[0].external])
  description = "the IP address and port of the nodered container"
}