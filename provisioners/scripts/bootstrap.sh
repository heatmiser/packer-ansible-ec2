#!/usr/bin/env bash

## BASH OPTIONS #############################################################

set -ex

### VARIABLES ###############################################################

SCRIPT_DIR=$(cd -- "$(dirname -- ${BASH_SOURCE[0]})" &> /dev/null && pwd)

## VERSIONS
VER_ANSIBLE_CORE="2.11.7"
VER_PYTHON="3.9"

## TOGGLES

# 1 for yes, 0 for no
BOOL_GPG_VERIFY_AWS_CLI=1

## COMMANDS
CMD_PKG_MGR="dnf"
CMD_PYTHON="python${VER_PYTHON}"

## URLS

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
URL_AWS_CLI_PKG="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

## PACKAGES

# dnf
PKG_DNF_PYTHON="python$(echo ${VER_PYTHON} | tr -d '.')" 
PKG_DNF_ZIP="zip"
PKG_DNF_DEV_GROUP="@development"
PKG_DNF_GPG="gnupg2"

# python
PKG_PYTHON_ANSIBLE_CORE="ansible-core==${VER_ANSIBLE_CORE}"
PKG_PYTHON_JMESPATH="jmespath"
PKG_PYTHON_WHEEL="wheel"

# Directories/Files/Paths
TMP_DIR="/tmp"
TMP_MANIFEST_PATH="${TMP_DIR}/manifest.zip"
REQUIREMENTS_GALAXY="${TMP_DIR}/requirements.yml"

# GPG signatures
GPG_AWS_PUB_SIGNATURE_FILE="${SCRIPT_DIR}/aws_pub.pgp"

export PYVENV_PROJDIR="${TMP_DIR}/ansible_venv"

# CREDENTIALS
# AWS_ACCESS_KEY_ID provided as an environment variable by packer
# AWS_SECRET_ACCESS_KEY provided as an environment variable by packer

# Strings
STR_SED_PLACEHOLDER="AABBccddeeff112233gghh"

### FUNCTIONS ###############################################################

# Install Linux packages
dnf_install_packages()
{
 # no quotes on ${@} for variable expansion
 _dnf install $@
}

dnf_remove_packages()
{
 # no quotes on ${@} for variable expansion
 _dnf remove $@
}

# dnf package manager
_dnf()
{
  if [[ ! -z "$@" ]];
  then
    # no quotes on ${@:2} as need to have variable expansion
    sudo "${CMD_PKG_MGR}" -y "${1}" ${@:2}
  fi
}

# Install python modules using pip
# Loop, so that each argument can specify parameters to pip
pip_install_packages()
{
  if [[ ! -z "${@}" ]];
   then
   for pip_pkg in "${@}"
   do
     # don't use quotes around ${pip_pkg} so the string is expanded to args
     "${CMD_PYTHON}" -m pip install ${pip_pkg}
   done
  fi
}

function import_aws_pgp_pub_sig()
{
AWS_PGP_PUBLIC_SIGNATURE=$(cat << EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4WIQT7
Xbd/1cEYuAURraimMQrMRnJHXAUCXYKvtQIbAwUJB4TOAAULCQgHAgYVCgkICwIE
FgIDAQIeAQIXgAAKCRCmMQrMRnJHXJIXEAChLUIkg80uPUkGjE3jejvQSA1aWuAM
yzy6fdpdlRUz6M6nmsUhOExjVIvibEJpzK5mhuSZ4lb0vJ2ZUPgCv4zs2nBd7BGJ
MxKiWgBReGvTdqZ0SzyYH4PYCJSE732x/Fw9hfnh1dMTXNcrQXzwOmmFNNegG0Ox
au+VnpcR5Kz3smiTrIwZbRudo1ijhCYPQ7t5CMp9kjC6bObvy1hSIg2xNbMAN/Do
ikebAl36uA6Y/Uczjj3GxZW4ZWeFirMidKbtqvUz2y0UFszobjiBSqZZHCreC34B
hw9bFNpuWC/0SrXgohdsc6vK50pDGdV5kM2qo9tMQ/izsAwTh/d/GzZv8H4lV9eO
tEis+EpR497PaxKKh9tJf0N6Q1YLRHof5xePZtOIlS3gfvsH5hXA3HJ9yIxb8T0H
QYmVr3aIUes20i6meI3fuV36VFupwfrTKaL7VXnsrK2fq5cRvyJLNzXucg0WAjPF
RrAGLzY7nP1xeg1a0aeP+pdsqjqlPJom8OCWc1+6DWbg0jsC74WoesAqgBItODMB
rsal1y/q+bPzpsnWjzHV8+1/EtZmSc8ZUGSJOPkfC7hObnfkl18h+1QtKTjZme4d
H17gsBJr+opwJw/Zio2LMjQBOqlm3K1A4zFTh7wBC7He6KPQea1p2XAMgtvATtNe
YLZATHZKTJyiqA==
=vYOk
-----END PGP PUBLIC KEY BLOCK-----
EOF
)
  echo -e "${AWS_PGP_PUBLIC_SIGNATURE}" | gpg --import
}

# first parameter is sig file
# second parameter is file
gpg_check_file()
{
  dnf_install_packages "${PKG_DNF_GPG}"
  import_aws_pgp_pub_sig
  # From [gnupg] man page:
  #   - 0 if there are no severe errors
  #   - 1 if at least a signature was bad,
  #   - x != 0 other non-zero error codes for fatal error
  #   Ref: https://www.gnupg.org/documentation/manuals/gpgme/Error-Codes.html
  #
  #   || = test for nonzero, if so, then branch { }
  gpg --verify "${1}" "${2}" ||
  {
    echo "FATAL: AWS gpg signature verify has failed on awscliv2.zip"
    exit 1
  }
  echo "OK: AWS gpg signature was successfully verified on awscliv2.zip"
}

copy_from_s3()
{
   AWS_CLI_ZIP_ABS_PATH="${TMP_DIR}/awscliv2.zip"

   # Download the package from AWS
   curl "${URL_AWS_CLI_PKG}" -o "${AWS_CLI_ZIP_ABS_PATH}"

   # Test gpg/pgp signature
   if [[ "${BOOL_GPG_VERIFY_AWS_CLI}" -ne 0 ]];
   then
     # Download the pgp signature file from aws
     curl "${URL_AWS_CLI_PKG}.sig" -o "${AWS_CLI_ZIP_ABS_PATH}.sig"
     # first parameter is sig file
     # second parameter is file
     gpg_check_file "${AWS_CLI_ZIP_ABS_PATH}.sig" "${AWS_CLI_ZIP_ABS_PATH}"
   fi
   # gpg_check_file function hard exits with exit code 1 if the pgp check fails

   # If we're here, then everything is fine
   # download zip, unzip the aws cli and install it
   dnf_install_packages "${PKG_DNF_ZIP}"
   unzip "${AWS_CLI_ZIP_ABS_PATH}" -d "${TMP_DIR}" | grep "/install"
   sudo "${TMP_DIR}/aws/install" -i "${TMP_DIR}" -b "${TMP_DIR}/bin"

   "${TMP_DIR}/bin/aws" s3 cp "${1}" "${2}"
   sha256sum "${2}"
   file "${2}"
   ls -al "${2}"
   
   dnf_remove_packages "${PKG_DNF_ZIP}"
}

download_manifest()
{
 # Perform manifest download based on value supplied to 
 # [download protocol]
 #
 # Valid values:
 #
 # - "s3"   | Use amazon [s3] cli to download an asset in [s3]
 # - "curl" | Use [curl] to download an asset over http/s
 # - ""     | default will use [curl]
 #
 case "${download_protocol}" in
  "s3")
   copy_from_s3 "${satellite_manifest}" "${TMP_MANIFEST_PATH}"
   ;;
   # for option "curl" and if not defined
    *)
   curl -L "${satellite_manifest}" -o "${TMP_MANIFEST_PATH}"  
 esac
}

setup_python_venv()
{
 # Install pip and create venv
 "${CMD_PYTHON}" -m pip install --user --upgrade pip setuptools
 "${CMD_PYTHON}" -m venv "${PYVENV_PROJDIR}"
 "${CMD_PYTHON}" -m pip install --upgrade pip
  # load the python venv
  source "${PYVENV_PROJDIR}/bin/activate"
}

cleanup()
{
  # Purge history 
  history -c
}

### MAIN ####################################################################

# Replace string placeholder with supplied API token
echo "Turning logging off to sed RH API token"
set +x
sed -i "s/${STR_SED_PLACEHOLDER}/${api_token}/g" ~/.ansible.cfg
set -x
echo "Logging back on"

# download the Satellite manifest supplied in the packer-build.json file
download_manifest

# Install python and required packages
dnf_install_packages "${PKG_DNF_DEV_GROUP}" "$PKG_DNF_PYTHON"

# RC: commented out - venv will create dir if does not exist
# mkdir -p "${PYVENV_PROJDIR}"

# create the python virtual environment
setup_python_venv

# Upgrade pip and install wheel python module
pip_install_packages \
  "${PKG_PYTHON_WHEEL}" \
  "${PKG_PYTHON_ANSIBLE_CORE}" \
  "${PKG_PYTHON_JMESPATH}"

# Install collects from requirements.yml
ansible-galaxy collection install -r "${REQUIREMENTS_GALAXY}" --force

# Remove packages not needed after bootstrap and purge history
cleanup

