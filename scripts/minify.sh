#!/bin/bash
set -e

# docker run --rm --platform linux/amd64 -v "$(pwd)/_site":/srv -w /srv tdewolff/minify --exclude "files/**" -r -o /srv .

# Capture file sizes before minification
echo "Calculating file sizes before minification..."
before=$(find _site -type f -exec stat --format='%n %s' {} \; | sort)

echo "Size before HTML/CSS/JS minification:"
du -sh _site

# Run the minification command (excluding the 'files' directory)
docker run --rm --platform linux/amd64 \
  -v "$(pwd)/_site":/srv \
  -w /srv \
  tdewolff/minify --exclude "files/**" -r -o /srv .

echo "Size after HTML/CSS/JS minification:"
du -sh _site

# Capture file sizes after minification
echo "Calculating file sizes after minification..."
after=$(find _site -type f -exec stat --format='%n %s' {} \; | sort)

# Save the before and after data into temporary files
tmp_before=$(mktemp)
tmp_after=$(mktemp)

echo "$before" > "$tmp_before"
echo "$after" > "$tmp_after"

echo "Files with increased size:"
./scripts/detect-size-increase.rb "$tmp_before" "$tmp_after"

# Clean up temporary files
rm "$tmp_before" "$tmp_after"

# Build imagemin Dockerfile
# docker build --progress plain -t argmin-gravitas/imagemin -f Dockerfiles/Dockerfile.imagemin .

# echo "Size before image minification"
# du -sh _site

# docker run --rm -v "$(pwd)/_site":/images argmin-gravitas/imagemin '/images/**/*.{jpg,jpeg,png,gif}' --out-dir=/images

# echo "Size after image minification"
# du -sh _site