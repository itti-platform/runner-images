packer {
  required_plugins {
    docker = {
      # usar 1.0.8
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "sa-east-1"  
}

variable "repository_name" {
  type    = string
}

variable "tags" {
  type    = list(string)
  default = ["latest"]
}


variable "helper_script_folder" {
  type    = string
  default = "/imagegeneration/helpers"
}

variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}

variable "installer_script_folder" {
  type    = string
  default = "/imagegeneration/installers"
}

source "docker" "ubuntu" {
  image  = "ubuntu:22.04"
  pull = false
  commit = true
}

build {
  sources = ["source.docker.ubuntu"]
  name = "selhosted-ubuntu22.04"

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "DEBIAN_FRONTEND=noninteractive"]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get install sudo lsb-release wget curl jq perl unzip software-properties-common apt-transport-https ca-certificates parallel rsync mysql-client -yq",
      "mkdir -p /usr/share/dotnet/shared",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -",
      "curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/msprod.list",
      "add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "apt-get update",
      "apt-get install docker-ce docker-ce-cli containerd.io -yq"
    ]
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["mkdir ${var.image_folder}", "chmod 777 ${var.image_folder}"]
  }

  provisioner "file" {
    destination = "${var.helper_script_folder}"
    source      = "${path.root}/../scripts/helpers"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}"
    source      = "${path.root}/../scripts/build"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}/toolset.json"
    source      = "${path.root}/../toolsets/toolset-2204.json"
  }

  # Ignore original tests
  provisioner "shell" {
    inline = [
      "echo '#!/bin/bash' > /usr/local/bin/invoke_tests",
      "echo 'echo \"Tests skipped ;) -> $*\"' >> /usr/local/bin/invoke_tests",
      "chmod +x /usr/local/bin/invoke_tests"
    ]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c 'yes | {{ .Vars }} {{ .Path }}'"
    scripts          = [
      # "${path.root}/../scripts/build/install-mysql.sh",
      "${path.root}/../scripts/build/install-mssql-tools.sh",
      "${path.root}/../scripts/build/install-dotnetcore-sdk.sh",
      "${path.root}/../scripts/build/install-actions-cache.sh",
      "${path.root}/../scripts/build/install-runner-package.sh",
      "${path.root}/../scripts/build/install-apt-common.sh",
      "${path.root}/../scripts/build/install-azcopy.sh",
      "${path.root}/../scripts/build/install-azure-cli.sh",
      "${path.root}/../scripts/build/install-azure-devops-cli.sh",
      "${path.root}/../scripts/build/install-bicep.sh",
      "${path.root}/../scripts/build/install-aliyun-cli.sh",
      "${path.root}/../scripts/build/install-apache.sh",
      "${path.root}/../scripts/build/install-aws-tools.sh",
      "${path.root}/../scripts/build/install-clang.sh",
      "${path.root}/../scripts/build/install-swift.sh",
      "${path.root}/../scripts/build/install-cmake.sh",
      "${path.root}/../scripts/build/install-codeql-bundle.sh",
      "${path.root}/../scripts/build/install-container-tools.sh",
      # "${path.root}/../scripts/build/install-firefox.sh",
      # "${path.root}/../scripts/build/install-microsoft-edge.sh",
      "${path.root}/../scripts/build/install-gcc-compilers.sh",
      "${path.root}/../scripts/build/install-gfortran.sh",
      "${path.root}/../scripts/build/install-git.sh",
      "${path.root}/../scripts/build/install-git-lfs.sh",
      "${path.root}/../scripts/build/install-github-cli.sh",
      # "${path.root}/../scripts/build/install-google-chrome.sh",
      # "${path.root}/../scripts/build/install-google-cloud-cli.sh",
      # "${path.root}/../scripts/build/install-haskell.sh",
      "${path.root}/../scripts/build/install-heroku.sh",
      "${path.root}/../scripts/build/install-java-tools.sh",
      "${path.root}/../scripts/build/install-kubernetes-tools.sh",
      "${path.root}/../scripts/build/install-oc-cli.sh",
      "${path.root}/../scripts/build/install-leiningen.sh",
      "${path.root}/../scripts/build/install-miniconda.sh",
      "${path.root}/../scripts/build/install-mono.sh",
      "${path.root}/../scripts/build/install-kotlin.sh",
      "${path.root}/../scripts/build/install-sqlpackage.sh",
      "${path.root}/../scripts/build/install-nginx.sh",
      "${path.root}/../scripts/build/install-nvm.sh",
      "${path.root}/../scripts/build/install-nodejs.sh",
      "${path.root}/../scripts/build/install-bazel.sh",
      "${path.root}/../scripts/build/install-oras-cli.sh",
      "${path.root}/../scripts/build/install-php.sh",
      "${path.root}/../scripts/build/install-postgresql.sh",
      "${path.root}/../scripts/build/install-pulumi.sh",
      "${path.root}/../scripts/build/install-ruby.sh",
      "${path.root}/../scripts/build/install-rlang.sh",
      "${path.root}/../scripts/build/install-rust.sh",
      "${path.root}/../scripts/build/install-julia.sh",
      "${path.root}/../scripts/build/install-sbt.sh",
      "${path.root}/../scripts/build/install-selenium.sh",
      "${path.root}/../scripts/build/install-terraform.sh",
      "${path.root}/../scripts/build/install-packer.sh",
      "${path.root}/../scripts/build/install-vcpkg.sh",
      # "${path.root}/../scripts/build/configure-dpkg.sh",
      "${path.root}/../scripts/build/install-yq.sh",
      "${path.root}/../scripts/build/install-android-sdk.sh",
      "${path.root}/../scripts/build/install-pypy.sh",
      "${path.root}/../scripts/build/install-python.sh",
      "${path.root}/../scripts/build/install-zstd.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-pipx-packages.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "DEBIAN_FRONTEND=noninteractive", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "/bin/sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-homebrew.sh"]
  }

  post-processors {
    docker-push {
      ecr {
        region           = var.aws_region
        repository_name  = var.repository_name
        tag              = var.tags
      }
    }
  }
}
