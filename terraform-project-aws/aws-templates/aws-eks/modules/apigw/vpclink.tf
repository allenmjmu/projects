resource "aws_apigatewayv2_api_link" "Projectvpclink" {
  name = "Projectvpclink"
  security_group_ids = var.security_group_ids
  subnet_ids = var.subnet_ids

  tags = {
    Usage = "Projectvpclink"
  }
}