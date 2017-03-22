
terraform {
        backend "s3" {
                bucket = "io-ajk-terraform-state-files"
                key = "io-ajk-green-vpc.tfstate"
                region = "eu-west-1"
                encrypt = "true"
                lock_table = "terraform_locks"
        }
}

