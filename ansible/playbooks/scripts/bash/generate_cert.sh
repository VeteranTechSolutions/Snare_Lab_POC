#!/bin/bash

# Step 1: Generate the Private Key
# This command creates a 2048-bit private RSA key and stores it in a file.
# It's the first step in securing your HTTPS communications.
openssl genrsa -out snaretraininglab.local.key 2048
echo "Private key created."

# Step 2: Generate the Certificate Signing Request (CSR)
# The CSR contains information that will be included in the certificate such as
# the organization name, common name (domain name), locality, and country.
# The 'openssl req' command prompts you to enter this information.
# The most important part here is the Common Name (CN) which should be the domain name.
echo "Generating CSR. Please follow the prompts."
openssl req -new -key snaretraininglab.local.key -out snaretraininglab.local.csr
echo "CSR created."

# Step 3: Generate the Self-Signed Certificate
# This command uses the private key and CSR to create a self-signed certificate.
# Self-signed certificates are great for testing and internal usage.
# The certificate is set to expire after 365 days.
openssl x509 -req -days 365 -in snaretraininglab.local.csr -signkey snaretraininglab.local.key -out snaretraininglab.local.crt
echo "Self-signed certificate created."

# Step 4: Export to PFX Format
# This step combines the private key and the certificate into a single PFX file.
# PFX files are used to securely exchange cryptographic keys and certificates in Windows environments.
# You'll be prompted to create a password to secure the PFX file.
echo "Exporting to PFX format. You will be prompted to set a password."
openssl pkcs12 -export -out snaretraininglab.local.pfx -inkey snaretraininglab.local.key -in snaretraininglab.local.crt
echo "PFX file created."

echo "All tasks completed successfully. Your files are ready for use."
