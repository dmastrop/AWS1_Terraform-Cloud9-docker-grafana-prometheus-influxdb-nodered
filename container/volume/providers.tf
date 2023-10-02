# This is for container/volume.providers.tf. This is the same content as the
# container/providers.tf

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      # this is the api for docker that we will use.
      #version = "2.12.0"
      #version = "2.15.0"
      # this is a test version and will be blocked by the .terraform.lock.hcl file.
      # my setup is currently at 
      # version = "3.0.2"
      # to get the 2.15.0 to take must do a    terraform init -upgrade
      
      # to prevent an upgrade on second number do this:
      #  version = "~> 2.12.0"  this will allow any 2.12.x but not 2.15
      
      # version  = "~> 2.12" will allow 2.x but not 3.x.  Rightmost number can increase as much as possible without next left number incrementing.
      
      # version = "~> 2.15.0" will lock it to 2.15.x 
      #version = "~> 2.15.0"
      # commenting this out will bring it to the latest 3.0.2 version. This did not work. 
      # with version 0.14+ of terraform, the version should no longer be reqired. not sure why I had to specify version.
      
      # try explicit version
      version = "3.0.2"
      
    }
  }
}