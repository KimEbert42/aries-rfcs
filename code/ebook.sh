#!/bin/bash

BOOK_PATH=$1
echo "Book path: $BOOK_PATH"

BOOK_DIR=`dirname "$BOOK_PATH"`
echo "Book Dir: $BOOK_DIR"

BOOK_TITLE=`grep '#' "$BOOK_PATH" | head -n 1 | sed 's/#//' | sed 's/ *\$//g' | sed 's/^ *//g' | sed 's/[^A-Za-z0-9 ]//g'`
if [ -z "$BOOK_TITLE" ]
then
  BOOK_TITLE="ARIES RFC"
fi
echo "Book title: $BOOK_TITLE"

BOOK_AUTHORS=`grep -i "Authors" "$BOOK_PATH" | head -n 1| sed 's/.*Authors: //' | sed 's/[][]*//g' | sed 's/([.:<>a-zA-Z0-9@]*)//g' | sed 's/[^A-Za-z0-9 ,]//g'`

if [ -z "$BOOK_AUTHORS" ]
then
  BOOK_AUTHORS="Blank"
fi

echo "Book authors: $BOOK_AUTHORS"

SOURCE_DATE=`stat -c %w "$BOOK_PATH"| date -f - --iso-8601`

# https://github.com/jgm/pandoc/issues/6539
export SOURCE_DATE_EPOCH=`stat -c %w "$BOOK_PATH" | date -f - +%s`

echo "Soucre Date Epoch $SOURCE_DATE_EPOCH"
echo "Source Date $SOURCE_DATE"

RFC_ID=`cat "$BOOK_PATH" | grep RFC | head -n 1 | grep -o -E '[0-9]{4}'`

echo "RFCID $RFC_ID"

# Epub file...
cat > "$BOOK_PATH.epub.yaml" <<EOF
---
title:
- type: main
  text: $BOOK_TITLE
creator:
- role: author
  text: $BOOK_AUTHORS
date: $SOURCE_DATE
date-meta: $SOURCE_DATE
identifier:
- scheme: DOI
  text: urn:aries:rfc:$RFC_ID
EOF

# Metadata file
cat > "$BOOK_PATH.yaml" <<EOF
---
title: $BOOK_TITLE
author: $BOOK_AUTHORS
date: $SOURCE_DATE
date-meta: $SOURCE_DATE
EOF

# Use docker for consitent pandoc
docker run --rm --volume "`pwd`:/data" --user `id -u`:`id -g` -e SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH pandoc/latex:2 -f markdown_mmd "$BOOK_PATH" --metadata-file "$BOOK_PATH.yaml" --metadata-file "$BOOK_PATH.epub.yaml" --resource-path "$BOOK_DIR" -o "$BOOK_PATH.epub"

rm -f "$BOOK_PATH.yaml" "$BOOK_PATH.epub.yaml"
