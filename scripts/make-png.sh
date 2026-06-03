#!/bin/sh

for file in *.scad
do
  if [ "$file" = "std.scad" ]; then
    continue
  fi
  png=images/$(basename "$file" .scad).png
  echo "$file -> $png"
  openscad -o "$png" --imgsize 640,480 --viewall --colorscheme=Nature "$file"
done
