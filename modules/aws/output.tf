// output "vm" {
//   value = module.ec2
// }

output "appregionvmmap" {
  value = local.appregionvmmap
}

output "segmentmap" {
  value = local.segmentmap
}

output "sgtest" {
  value = format("sgroup-[uni/tn-%s/cloudapp-%s/cloudepg-%s]", var.tenant, each.value.app_name, each.value.tier)
}
