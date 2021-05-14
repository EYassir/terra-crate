output "crate_dns_lb" {
  value = aws_lb.crate_lb.dns_name
}
