#!/bin/bash
set -e

echo "Size before minification"
du -sh _site

docker run --rm --platform linux/amd64 -v "$(pwd)/_site":/srv tdewolff/minify -r -o /srv .

echo "Size after minification"
du -sh _site