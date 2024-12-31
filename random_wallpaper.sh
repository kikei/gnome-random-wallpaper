#!/bin/bash

encodeurl() {
    eval "$1=\"$(jq -nr --arg v "$2" '$v | @uri')\""
}

# Wallhaven settings
QUERY="cats"
RATIO="16x9,16x10,21x9,32x9,48x9"
ATLEAST="1280x720"
CATEGORY="111"
PURITY="110"

# Gnome settings
IMAGE_DIR="/tmp/random_wallpaper"
GNOME_BACKGROUND_KEY="picture-uri-dark"
GNOME_BACKGROUND_OPTIONS="zoom"

# See https://wallhaven.cc/help/api
encodeurl q "$QUERY"
randomize_uri="https://wallhaven.cc/api/v1/search?q=$q&atleast=$ATLEAST&ratios=$RATIO&categories=$CATEGORY&purity=$PURITY&sorting=date_added"

echo "Fetching random image from $randomize_uri"

if ! response="$(curl -s "$randomize_uri")"; then
    echo "Error: Failed to fetch data" >&2
    exit 1
fi

pages="$(echo "$response" | jq -r '.meta.last_page')"
seed="$(echo "$response" | jq -r '.meta.seed')"
echo "Found $pages pages"

# Get a random page from the results
page=$((RANDOM % pages + 1))
echo "Choosing page $page"

if [ "$page" -ne 1 ]; then
    echo "Refetching with page=$page and seed=$seed"
    randomize_uri="$randomize_uri&page=$page&seed=$seed"
    response="$(curl -s "$randomize_uri")"
fi

count="$(echo "$response" | jq -r '.data | length')"
echo "Found $count images"

if [ "$count" -eq 0 ]; then
    echo "No images found"
    exit 1
fi

# Get a random image from the results
index=$((RANDOM % count))
echo "Choosing image $index"

image_url=$(echo "$response" | jq -r ".data[$index].path")

image_name="${image_url##*/}"
image_path="$IMAGE_DIR/$image_name"

# Create the directory if it doesn't exist
mkdir -p "$IMAGE_DIR"

echo "Downloading $image_url to $IMAGE_DIR"

# Download the image to IMAGE_DIR with it's extension
curl -s -o "$image_path" "$image_url"

echo "Downloaded."
echo "Setting $image_name as wallpaper"

gsettings set org.gnome.desktop.background "$GNOME_BACKGROUND_KEY" "file://$image_path"
gsettings set org.gnome.desktop.background picture-options "$GNOME_BACKGROUND_OPTIONS"

echo "Done"
