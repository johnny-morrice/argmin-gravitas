#!/bin/bash
set -e

echo "Size before minification"
du -sh _site

docker run --rm -v "$(pwd)/_site":/srv tdewolff/minify -r -o /srv /srv

echo "Size after minification"
du -sh _site