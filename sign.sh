#!/bin/bash -ex

X=$1
Y=$2
S=$3
PIC=$(realpath $4)
SRC="$5"
P=$6
TMPDIR=$(mktemp -d)
TEX=$TMPDIR/sig.tex
STAMP=$TMPDIR/sig.pdf
PAGE=$TMPDIR/page.pdf
SPAGE=$TMPDIR/spage.pdf
DST=$(echo "$SRC" | sed -e 's/\.pdf$/-signed.pdf/')

cat <<END >$TEX
\\documentclass[a4paper]{article}

\\usepackage{fullpage}
\\pagestyle{empty}

\\usepackage{graphicx}
\\usepackage{tikz}

\\begin{document}

\\begin{tikzpicture}[remember picture,overlay,shift=(current page.south west)]
  \\node at (${X},${Y}) [anchor=base west] {\\includegraphics[scale=${S}]{${PIC}}};
\\end{tikzpicture}

\\end{document}
END

pdftk "$SRC" cat $P output $PAGE
pdflatex -output-directory $TMPDIR $TEX
pdflatex -output-directory $TMPDIR $TEX
pdftk $PAGE stamp $STAMP output $SPAGE
rm -f $DST

LASTPAGE=$(pdftk "$SRC" dump_data output | grep -Po '^NumberOfPages: \K\d+')
POST=
PRE=

if [ $P -ne 1 ]; then
  PRE="A1-$(($P-1))"
fi

if [ $P -ne $LASTPAGE ]; then
  POST="A$((P+1))-end"
fi

pdftk A="$SRC" B=$SPAGE cat $PRE B1 $POST output "$DST"
rm -rf $TMPDIR
