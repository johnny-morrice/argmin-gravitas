#!/bin/bash
set -e

echo "Size before minification"
du -sh _site

docker run --rm --platform linux/amd64 -v "$(pwd)/_site":/srv tdewolff/minify:v2.21.3 -r -o /srv /srv

echo "Size after minification"
du -sh _site