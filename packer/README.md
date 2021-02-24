# Packer images

HashiCorp Packer automates the creation of any type of machine image with the prepared scripts. The source image based on `Debbian 9 (stretch)`

## Build GCP image
1. Create a custom service account for Packer and assign it:  
    `Compute Instance Admin (v1)` & `Service Account User` (https://www.packer.io/docs/builders/googlecompute#running-on-google-cloud)

2. Set `PKR_VAR_account_file` path
    ```bash
    $ export PKR_VAR_account_file=/path/to/credential.json
    ```

3. Build GCP Opendax base image
    ```bash
    $ packer build -var project_id=your-project-id ./packer/gcp-image-base.json.pkr.hcl
    ```

4. Build GCP Opendax image
    ```bash
    $ packer build -var project_id=your-project-id ./packer/gcp-packer.json.pkr.hcl
    ```

## Build DigitalOcean image
1. Set `PKR_VAR_api_token` with your DitialOcean token.
   ```bash
   $ export PKR_VAR_api_token = YOUR_DIGITALOCEAN_API_TOKEN
   ```

2. Build DigitalOcean Opendax image
    ```bash
    $ packer build ./packer/do-packer.json.pkr.hcl
    ```

## Build AWS image
1. Set `PKR_VAR_access_key` & `PKR_VAR_secret_key` with your AWS credentials.
   ```bash
   $ export PKR_VAR_access_key = YOUR_AWS_ACCESS_KEY
   $ export PKR_VAR_secret_key = YOUR_AWS_SECRET_KEY
   ```

2. Build AWS Opendax image
    ```bash
    $ packer build ./packer/aws-packer.json.pkr.hcl
    ```
