#!/bin/bash

# Generate ebooks from md files. Depends upon bash, Calibre, and Pandoc

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo $SCRIPT_PATH
ROOT_PATH=`dirname "$SCRIPT_PATH"`
echo $ROOT_PATH

find $ROOT_PATH -type f | grep "\.md$" | xargs -P `nproc` -I xxx $SCRIPT_PATH/ebook.sh "xxx"
