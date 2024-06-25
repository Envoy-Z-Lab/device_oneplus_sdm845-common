#!/bin/bash

# Function to download and run keygen.sh script
run_keygen_script() {
    local url="https://raw.githubusercontent.com/Envoy-Z-Lab/Signing-Script/main/keygen.sh"
    echo "Downloading and running keygen.sh script..."
    bash <(curl -s $url)
}

# Function to create a zip archive of keys folder and upload it to Pixeldrain
upload_to_pixeldrain() {
    local keys_folder="vendor/lineage-priv/keys"
    local zip_file="keys.zip"
    echo "Creating zip archive of keys folder..."
    zip -r "$zip_file" "$keys_folder" >/dev/null
    echo "Uploading $zip_file to Pixeldrain..."
    upload_response=$(curl -s -F "file=@$zip_file" https://pixeldrain.com/api/file)
    upload_link=$(echo "$upload_response" | grep -o 'https://pixeldrain\.com/api/file/[^"]*')
    # Generate download link for the uploaded file
    download_link="${upload_link/api\/file/download}"
    echo "$download_link"
    # Clean up zip file after upload
    rm "$zip_file"
}

# Run the keygen.sh script from GitHub
run_keygen_script

# Upload the keys folder as a zip file to Pixeldrain and display the download link
download_link=$(upload_to_pixeldrain)

echo "Download link for the uploaded zip file:"
echo "$download_link"

echo "Vendor setup complete."
