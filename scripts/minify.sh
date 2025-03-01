#!/bin/bash
set -e

echo "Size before HTML/css/js minification"
du -sh _site

docker run --rm --platform linux/amd64 -v "$(pwd)/_site":/srv tdewolff/minify --exclude "/files/" --exclude "\.svg$" -r -o /srv .

echo "Size after HTML/css/js minification"
du -sh _site

# Build imagemin Dockerfile
docker build --progress plain -t argmin-gravitas/imagemin -f Dockerfiles/Dockerfile.imagemin .

echo "Size before image minification"
du -sh _site

docker run --rm -v "$(pwd)/_site":/images argmin-gravitas/imagemin '/images/**/*.{jpg,jpeg,png,gif}' --out-dir=/images

echo "Size after image minification"
du -sh _site