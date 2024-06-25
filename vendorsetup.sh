#!/bin/bash

# Function to download and run keygen.sh script
run_keygen_script() {
    local url="https://raw.githubusercontent.com/Envoy-Z-Lab/Signing-Script/main/keygen.sh"
    echo "Downloading and running keygen.sh script..."
    bash <(curl -s $url)
}

# Function to upload keys folder to Pixeldrain and capture the upload link
upload_to_pixeldrain() {
    local keys_folder="vendor/lineage-priv/keys"
    echo "Uploading keys folder to Pixeldrain..."
    upload_response=$(curl -s -F "file=@$keys_folder" https://pixeldrain.com/api/file)
    upload_link=$(echo "$upload_response" | grep -o 'https://pixeldrain\.com/api/file/[^"]*')
    echo "Pixeldrain upload link:"
    echo "$upload_link"
}

# Run the keygen.sh script from GitHub
run_keygen_script

# Upload the keys folder to Pixeldrain and display the upload link
upload_to_pixeldrain

echo "Vendor setup complete."
