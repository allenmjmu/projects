resource "aws_apigatewayv2_api" "example" {
  name = "ProjectApigw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "example" {
  api_id = aws_apigatewayv2_api.example.id
  route_key = "GET /example"
  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}

resource "aws_apigatewayv2_integration" "example" {
  api_id = aws_apigatewayv2_api.example.id
  integration_type = "HTTP_PROXY"
  integration_uri = "https://example.com/api"
  integration_method = "GET"
}

resource "aws_apigatewayv2_stage" "example" {
  api_id = aws_apigatewayv2_api.example.id
  name = "prod"
  auto_deploy = true
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.example.api_endpoint
}