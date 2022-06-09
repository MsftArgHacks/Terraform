variable "VnetName" {
    type = string
    description = "VNet name of the App Service's virtual network"
}

variable "RGName" {
    type = string
}


variable "Location" {
    type = string
}

variable "AddressSpace"{
    type = list(string)
}

variable "SubnetName" {
    type = string
}

variable "AddressPrefix"{
    type = string
}

variable "Tags"{
    type = map
}