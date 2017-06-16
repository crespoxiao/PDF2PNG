#!/bin/bash
#
# 需要安装 Ghostscript，brew install gs
# 使用示例 ./pdf2png.sh xx.xcassets
# TODO: 递归遍历目录，实现全自动化 

if [[ $# < 1 ]]; then
  echo "Usage:" >&1
  echo "  convert-assets /assets " >&1
  exit 1
fi

ASSETS_DIR="$PWD/$1"

if [[ ! -d "$ASSETS_DIR" ]]; then
  echo "Assets directory $ASSETS_DIR does not exist" >&2
  exit 1
fi

#
# convert
#

CONVERT_PDF="gs -q -dNOPAUSE -dBATCH -sDEVICE=pngalpha -dEPSCrop -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dDownScaleFactor=3"

for FILE_PATH in $ASSETS_DIR/**/*.pdf; do
  FILE="${FILE_PATH##*/}"
  FILE_NAME="${FILE%.*}"
  IMAGESET_DIR_PATH="$( dirname $FILE_PATH )"

  if [[ "$FILE_NAME" != "*" ]]; then

    ( \
        $CONVERT_PDF -r432 -sOutputFile="$IMAGESET_DIR_PATH/$FILE_NAME"@2x.png "$FILE_PATH" ;\
        $CONVERT_PDF -r648 -sOutputFile="$IMAGESET_DIR_PATH/$FILE_NAME"@3x.png "$FILE_PATH" \
    ) || true

    IMAGE_2X=`echo "${FILE_NAME}@2x.png"`
    IMAGE_3X=`echo "${FILE_NAME}@3x.png"`

    CONTENTS_PATH="$IMAGESET_DIR_PATH/Contents.json"
    rm -rf "$CONTENTS_PATH"

    CONTENTS="{\"images\":[{\"idiom\":\"universal\",\"scale\":\"1x\"},{\"idiom\":\"universal\",\"filename\":\"${IMAGE_2X}\",\"scale\":\"2x\"},{\"idiom\":\"universal\",\"filename\":\"${IMAGE_3X}\",\"scale\":\"3x\"}],\"info\":{\"version\":1,\"author\":\"xcode\"}}"
    echo $CONTENTS > $CONTENTS_PATH

    echo "create Contents.json success at ${CONTENTS_PATH}"

   # delete pdf file
   #find "$IMAGESET_DIR_PATH" -type f -not \( -name '*png' -or -name '*json' \) -delete
    echo "convert success at ${IMAGESET_DIR_PATH}"
  fi

done




