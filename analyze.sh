#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
RUN_DIR="$(pwd)"

echo $SCRIPT_DIR
echo $RUN_DIR

split-threaddump () {
  gcsplit -z --prefix=$1 --digits=1 $1 '/dump Java HotSpot/' '{*}'

  for file in $1?; do
    cat "$file" | perl -pe 's/^.*?\]: //e;' > "$file.clean"
    rm "$file"
  done
}

if [ -d "$SCRIPT_DIR/tmp" ]; then
  echo "Temporary directory already found, please open the relevant files yourself."
  echo ""
  echo "open \"$SCRIPT_DIR/tmp\""
  exit 1
else
  mkdir -p "$SCRIPT_DIR/tmp"
fi

# split the thread dump files
if test -z "$(find . -maxdepth 1 -name '*.clean' -print -quit)"; then
  find . -name '*.log' | while read file; do split-threaddump "$file"; done 
fi

for file in *.log0.clean; do  
  FILE=$file perl -pe 's/\${thread-dump}/`cat $ENV{"FILE"}`/ge' "$SCRIPT_DIR/index.html.tmpl" > "$SCRIPT_DIR/tmp/$file.html"
done;

find "$SCRIPT_DIR/tmp" -name '*.html' | xargs open
