// output "region" {
//   value = "${lookup(var.configuration, var.environment).region}"
// }

output "size" {
  value = "${lookup(var.configuration, var.environment).size}"
}
