locals {
  vpc_cidr = "10.123.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "public access"
      ingress = {
        open = {
          from        = 0
          to          = 0
          protocol    = -1
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        frontend = {
          from        = 3000
          to          = 3000
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
    subscription = {
      name        = "subscription_sg"
      description = "subscription access"
      ingress = {
        subscription = {
          from        = 8080
          to          = 8080
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
    mongodb = {
      name        = "mongodb_sg"
      description = "mongodb access"
      ingress = {
        mongodb = {
          from        = 27018
          to          = 27018
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
    efs = {
      name        = "efs_sg"
      description = "efs access"
      ingress = {
        efs = {
          from        = 2049
          to          = 2049
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}

locals {
  email_templates = {
    please_confirm = {
      name    = "please-confirm"
      subject = "Welcome to Web at Speed - Please confirm your email address"
    }
    please_wait = {
      name    = "please-wait"
      subject = "You confirmed your email address - CV coming up"
    }
    please_approve = {
      name    = "please-approve"
      subject = "CV requested"
    }
    first_cv = {
      name    = "first-cv"
      subject = "A Web at Speed CV"
    }
    updated_cv = {
      name    = "updated-cv"
      subject = "CV updated"
    }
    goodbye_subscriber = {
      name    = "goodbye-subscriber"
      subject = "CV unsubscribed"
    }
  }
}
