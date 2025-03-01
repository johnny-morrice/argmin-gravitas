#!/bin/bash
set -e

# Commented code here is for debugging purposes, using ruby script that calculates before/after sizes and new/removed files.

# Capture file sizes before minification
# echo "Calculating file sizes before minification..."
# before=$(find _site -type f -exec stat --format='%n %s' {} \; | sort)

echo "Size before HTML/CSS/JS minification:"
du -sh _site

# Run the minification command (excluding the 'files' directory)
docker run --rm --platform linux/amd64 \
  -v "$(pwd)/_site":/srv \
  -w /srv \
  tdewolff/minify sh -c 'mkdir -p /tmp/minify && minify --exclude -r -o /tmp/minify . && cp -a /tmp/minify/. . && rm -rf /tmp/minify'


echo "Size after HTML/CSS/JS minification:"
du -sh _site

# Capture file sizes after minification
# echo "Calculating file sizes after minification..."
# after=$(find _site -type f -exec stat --format='%n %s' {} \; | sort)

# Save the before and after data into temporary files
# tmp_before=$(mktemp)
# tmp_after=$(mktemp)

# echo "$before" > "$tmp_before"
# echo "$after" > "$tmp_after"

# echo "Files with increased size:"
# ./scripts/detect-size-increase.rb "$tmp_before" "$tmp_after"

# Clean up temporary files
# rm "$tmp_before" "$tmp_after"

# Build imagemin Dockerfile
docker build --platform linux/amd64 --progress plain -t argmin-gravitas/imagemagick -f Dockerfiles/Dockerfile.imagemagick .

echo "Size before image minification"
du -sh _site

echo "Compressing jpegs..."
docker run --rm --platform linux/amd64 \
  -v "$(pwd)/_site":/srv \
  argmin-gravitas/imagemagick \
  'find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec mogrify -strip -interlace Plane -quality 85 {} \;'

echo "Compressing pngs..."
docker run --rm --platform linux/amd64 \
  -v "$(pwd)/_site":/srv \
  my-imagemagick \
  'find . -type f -iname "*.png" -exec mogrify -strip -quality 85 {} \;'

echo "Compressing gifs..."
docker run --rm --platform linux/amd64 \
  -v "$(pwd)/_site":/srv \
  my-imagemagick \
  'find . -type f -iname "*.gif" -exec mogrify -strip {} \;'

echo "Size after image minification"
du -sh _site