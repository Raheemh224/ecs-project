resource "aws_ecr_repository" "ecsapp" {
  name                 = "ecsapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
}
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.ecsapp.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire old images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
