resource "aws_s3_bucket" "public_bucket" {
  bucket = "test-public-bucket-example-12345"
  acl    = "public-read"

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "none" {
  bucket = aws_s3_bucket.public_bucket.id
  # Intencional: Não define regras de criptografia para simular falta de SSE
}
