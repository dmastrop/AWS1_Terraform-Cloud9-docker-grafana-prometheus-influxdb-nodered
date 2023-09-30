## MOVE THE locals to a separate file (locals.tf) to clean things up. (STAGE4)

# NEW CODE for for_each implementation of image module (STAGE 3 below)
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/for-each
# https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
# keys are nodered and influxdb and valuses are the actual image.

locals {
  deployment = {
    # nodered = {
    #   # incorporate count into the for_each setup.  Copy this container_count from the locals of the root/variables.tf
    #   # Need to add the key ["nodered"] as well into this container_count definition
    #   container_count = length(var.ext_port["nodered"][terraform.workspace])
      
    #   image = var.image["nodered"][terraform.workspace]
      
    #   int = 1880
    #   ext = var.ext_port["nodered"][terraform.workspace]
    #   # this keys into the terraform.tfvars
      
    #   container_path  = "/data"
    # }
    
    
    
    # influxdb = {
    #   # incorporate count into the for_each setup.  Copy this container_count from the locals of the root/variables.tf
    #   # Need to add the key ["influxdb"] as well into this container_count definition
    #   container_count = length(var.ext_port["influxdb"][terraform.workspace])
    
    #   image = var.image["influxdb"][terraform.workspace]
      
    #   int = 8086
    #   ext = var.ext_port["influxdb"][terraform.workspace]
    #   # this keys into the terraform.tfvars
      
    #   container_path  = "/var/lib/influxdb"
    #   # this is from the influxdb registry docs on docker
    # }
    
    
    
    grafana = {
      # incorporate count into the for_each setup.  Copy this container_count from the locals of the root/variables.tf
      # Need to add the key ["grafana"] as well into this container_count definition
      container_count = length(var.ext_port["grafana"][terraform.workspace])
      
      image = var.image["grafana"][terraform.workspace]
      
      int = 3000
      ext = var.ext_port["grafana"][terraform.workspace]
      # this keys into the terraform.tfvars
      
      #container_path  = "/var/lib/granfana"
      
      # DYNAMIC BLOCK (step 1) for the container_paths. This will permit us to specify multiple container_paths
      # this block is created for each container, hence the name _each.
      # We want to create a volume for each of the volumes below listed
      # comment out the container_path above
      volumes = [
        {container_path_each = "/var/lib/grafana"},
        {container_path_each = "etc/grafana"}
      ]
    }
    
    
    
    # prometheus = {
    #   # incorporate count into the for_each setup.  Copy this container_count from the locals of the root/variables.tf
    #   # Need to add the key ["grafana"] as well into this container_count definition
    #   container_count = length(var.ext_port["prometheus"][terraform.workspace])
      
    #   image = var.image["prometheus"][terraform.workspace]
      
    #   int = 9090
    #   ext = var.ext_port["prometheus"][terraform.workspace]
    #   # this keys into the terraform.tfvars
      
    #   container_path  = "/opt/bitnami/prometheus/data"
    # }
    
    
  } # for deployment
} # for locals