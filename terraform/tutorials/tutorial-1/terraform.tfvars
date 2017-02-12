# ---
# Tutorial definition
# ---
  
name = "tutorial"
region = "us-east-1"
  
vpc_cidr        = "10.249.0.0/16"
azs             = "us-east-1c"

# Configure Terragrunt to use DynamoDB for locking
terragrunt = {
  lock = {
    backend = "dynamodb"
    config {
      state_file_id = "tutorial-1"
    }
  }

  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state = {
    backend = "s3"
    config {
      encrypt = "true"
      bucket = "terraform-tutorial-1-state-files"
      key = "tutorial-1.tfstate"
      region = "us-east-1"
    }
  }
}

