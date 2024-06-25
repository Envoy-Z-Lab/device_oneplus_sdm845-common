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

    # Move keys to vendor directory
    mkdir -p vendor/lineage-priv
    mv ~/.android-certs vendor/lineage-priv/keys
    echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey" > vendor/lineage-priv/keys/keys.mk

    # Create BUILD.bazel file
    cat <<EOF > vendor/lineage-priv/keys/BUILD.bazel
filegroup(
    name = "android_certificate_directory",
    srcs = glob([
        "*.pk8",
        "*.pem",
    ]),
    visibility = ["//visibility:public"],
)
EOF

    echo "Keys generated successfully."
}

# Function to upload keys to Pixeldrain and retrieve download link
upload_to_pixeldrain() {
    local keys_folder="vendor/lineage-priv/keys"
    local zip_file="keys.zip"
    echo "Creating zip archive of keys folder..."
    zip -r "$zip_file" "$keys_folder" >/dev/null
    echo "Uploading $zip_file to Pixeldrain..."
    upload_response=$(curl -s -F "file=@$zip_file" https://pixeldrain.com/api/file)
    upload_link=$(echo "$upload_response" | grep -o 'https://pixeldrain\.com/api/file/[^"]*')
    download_link="${upload_link/api\/file/download}"
    echo "$download_link"
}

# Generate Android keys automatically
generate_android_keys

# Upload keys to Pixeldrain and display download link
download_link=$(upload_to_pixeldrain)

echo "Download link for the uploaded zip file:"
echo "$download_link"

echo "Vendor setup complete."
