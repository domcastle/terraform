# variable "user_names" {
#   default = ["red", "blue", "green"]
# }
# output "upper_user_names"{
#   value = [for name in var.user_names: upper(name)]
# }

##### for expression - map input #####
variable "hero_thousand_faces" {
  description = "map"
  type        = map(string)
  default     = {
    neo      = "hero"
    trinity  = "love interest"
    morpheus = "mentor"
  }
}
output "bios" {
  value = [for name,role in var.hero_thousand_faces: "${name} is the ${role}"]
}
