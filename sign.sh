#!/bin/bash -ex

X=$1
Y=$2
S=$3
PIC=$(realpath $4)
SRC="$5"
PNUM=$6
PAPER=${7:-a4paper}

TMPDIR=$(mktemp -d)
TEX=$TMPDIR/sig.tex
PAGE=$TMPDIR/page.pdf
SPAGE=$TMPDIR/sig.pdf
DST=$(echo "$SRC" | sed -e 's/\.pdf$/-signed.pdf/')

cat <<END >$TEX
\\documentclass[${PAPER}]{article}

\\usepackage{fullpage}
\\pagestyle{empty}

\\usepackage{graphicx}
\\usepackage{tikz}

\\begin{document}

\\begin{tikzpicture}[remember picture,overlay]
  \\node at (current page.center) [anchor=center] {\\includegraphics{${PAGE}}};
  \\node at (${X},${Y}) [anchor=base west] {\\includegraphics[scale=${S}]{${PIC}}};
\\end{tikzpicture}

\\end{document}
END

pdfseparate -f $PNUM -l $PNUM "$SRC" $PAGE
pdflatex -output-directory $TMPDIR $TEX
pdflatex -output-directory $TMPDIR $TEX
rm -f $DST

LASTPAGE=$(pdfinfo "$SRC" | grep -Po '^Pages:\s+\K\d+')
POST=()
PRE=()

if [ $PNUM -ne 1 ]; then
  PRE=("$SRC" "1-$((PNUM-1))")
fi

if [ $PNUM -ne $LASTPAGE ]; then
  POST=("$SRC" "$((PNUM+1))-")
fi

pdfjoin --rotateoversize 'false' -o "$DST" "${PRE[@]}" $SPAGE 1 "${POST[@]}"
rm -rf $TMPDIR
