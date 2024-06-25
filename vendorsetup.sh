#!/bin/bash

# Function to generate Android keys without user interaction
generate_android_keys() {
    # Define the subject line
    local subject='/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'

    echo "Using Subject Line:"
    echo "$subject"

    # Remove existing Android certificates if found
    if [ -d "$HOME/.android-certs" ]; then
        rm -rf "$HOME/.android-certs"
        echo "Old Android certificates removed."
    fi

    # Create Key without prompting
    mkdir -p ~/.android-certs
    for x in bluetooth media networkstack nfc platform releasekey sdk_sandbox shared testkey verifiedboot; do 
        ./development/tools/make_key ~/.android-certs/$x "$subject" <<< $'\n\n\n\n\n\n\n\n\n\n'
    done

    # Move keys to specified vendor directory
    mkdir -p vendor/derp/signing/keys
    mv ~/.android-certs vendor/derp/signing/keys
    echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/derp/signing/keys/releasekey" > vendor/derp/signing/keys/keys.mk

    # Create BUILD.bazel file if needed
    cat <<EOF > vendor/derp/signing/keys/BUILD.bazel
filegroup(
    name = "android_certificate_directory",
    srcs = glob([
        "*.pk8",
        "*.pem",
    ]),
    visibility = ["//visibility:public"],
)
EOF

    echo "Keys generated successfully in vendor/derp/signing/keys."
}

# Function to zip keys folder
zip_keys_folder() {
    local keys_folder="vendor/derp/signing/keys"
    local zip_file="keys.zip"
    echo "Creating zip archive of keys folder..."
    zip -r "$zip_file" "$keys_folder" >/dev/null
    echo "$zip_file"
}

# Function to upload keys to temp.sh and retrieve download link
upload_to_tempsh() {
    local zip_file="$1"
    local upload_url="https://temp.sh/upload"
    echo "Uploading $zip_file to temp.sh..."

    # Use curl to upload file via HTTP POST
    response=$(curl -F "file=@$zip_file" $upload_url 2>/dev/null)

    # Extract the URL from the response
    download_link=$(echo "$response" | grep -o 'https://temp.sh/[A-Za-z0-9]*')

    echo "$download_link"
}

# Generate Android keys automatically
generate_android_keys

# Zip keys folder
zip_file=$(zip_keys_folder)

# Upload keys to temp.sh and display download link
download_link=$(upload_to_tempsh "$zip_file")

echo "Download link for the uploaded zip file:"
echo "$download_link"

echo "Vendor setup complete."
