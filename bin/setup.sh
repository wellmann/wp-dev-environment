#!/usr/bin/env bash

# Set up directory structure
mkdir {plugins,themes}

# Download latest WordPress
latest_wp_url=https://wordpress.org/latest.zip
zip_name=$(basename "$latest_wp_url")
curl -O $latest_wp_url &&
unzip $zip_name &&
rm $zip_name