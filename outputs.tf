### moved all of this output code from main.tf to outputs.tf

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

## Adding in Count in version2 of main.tf, but comment these out for now
# what we need here is to index the resource docker_container.nodered_container by index, ie
# resource docker_container.nodered_container[0] and resource docker_container.nodered_container[1]

# output "Container_name1" {
#   #value = docker_container.nodered_container.name
#   value = docker_container.nodered_container[0].name
#   description = "this is the name of the container"
# }

# output "Container_name2" {
#   #value = docker_container.nodered_container-2.name
#   value = docker_container.nodered_container[1].name
#   description = "this is the name of the container-2"
# }

# replace the above 2 blocks for the name with a single block using the splat
# https://developer.hashicorp.com/terraform/language/expressions/splat

output "Container_names" {
  #value = docker_container.nodered_container.name
  value = docker_container.nodered_container[*].name
  description = "this is the names of the containers"
}




# optimizing the ip address output is more difficult. A simple double splat like this below does not worK:
# value = join(":", [docker_container.nodered_container[*].ip_address, docker_container.nodered_container[*].ports[0].external])
# this flatten + splat will not work either. It will apply but the ip addreses will be listed and then the ports all : separated. Not a good format.
# value = join(":", flatten([docker_container.nodered_container[*].ip_address, docker_container.nodered_container[*].ports[0].external]))
# flatten reduced one level of nesting so that it could be applied but this will not work.
# For loop (expression) is much better:  https://developer.hashicorp.com/terraform/language/expressions/for

# output "IP_address_and_port_1" {
# # outputs cannot contain spaces in name in newer versions
#   #value = join(":", [docker_container.nodered_container.ip_address, docker_container.nodered_container.ports[0].external])
#   value = join(":", [docker_container.nodered_container[0].ip_address, docker_container.nodered_container[0].ports[0].external])
#   description = "the IP address and port of the nodered container"
# }

# output "IP_address_and_port_2" {
# # outputs cannot contain spaces in name in newer versions
#   #value = join(":", [docker_container.nodered_container-2.ip_address, docker_container.nodered_container-2.ports[0].external])
#   value = join(":", [docker_container.nodered_container[1].ip_address, docker_container.nodered_container[1].ports[0].external])
#   description = "the IP address and port of the nodered container"
# }
 
 # use a "for" loop the optimize this code.
 # 
 output "IP_addresses_and_ports_pairs" {
# outputs cannot contain spaces in name in newer versions

  #value = join(":", [docker_container.nodered_container.ip_address, docker_container.nodered_container.ports[0].external])
  #value = join(":", [docker_container.nodered_container[0].ip_address, docker_container.nodered_container[0].ports[0].external])
  value = [for i in docker_container.nodered_container[*]: join(":", [i.ip_address],i.ports[*]["external"])]
  # [for i in docker_container.nodered_container[*]: i]    this will dump everything. But we can grep attributes out with i.ip_address for example
  # note that the i.ports[*] splat does not require brackets in the join because it returns a nested list with brackets
  # if we were to use i.ports[0] this would require brackets in the join because it returns an un-nested list
  # Thus alternate syntax: [for i in docker_container.nodered_container[*]: join(":", [i.ip_address], [i.ports[0]["external"]])]
  
  description = "the IP address and external port of each nodered container"
  
  # we added senstive = true to the varaibles.tf "ext_port" variable definition (this masked the external port in the output of terraform apply)
  # ...and this now requires us to add the sensitive=true
  # to the outputs.tf in this location to mask the data in the outputs as well.  The apply will not go through until this is also added.
  #  This is only a test. Comment it out again after testing....
  
  # sensitive = true
  
}