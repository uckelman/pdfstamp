#!/bin/bash -ex

X=$1
Y=$2
TXT=$3
SRC=$4
PNUM=$5
PAPER=${6:-a4paper}

TMPDIR=$(mktemp -d)
TEX=$TMPDIR/anno.tex
PAGE=$TMPDIR/page.pdf
SPAGE=$TMPDIR/anno.pdf
DST=$(echo $SRC | sed -e 's/\.pdf$/-anno.pdf/')

cat <<END >$TEX
\\documentclass[${PAPER}]{article}

\\usepackage{fullpage}
\\pagestyle{empty}

\\usepackage{graphicx}
\\usepackage{tikz}

\\begin{document}

\\begin{tikzpicture}[remember picture,overlay,shift=(current page.south west)]
  \\node at (0,0) [anchor=south west] {\\includegraphics{${PAGE}}};
  \\node at (${X},${Y}) [anchor=base west] {$TXT};
\\end{tikzpicture}

\\end{document}
END

pdfseparate -f $PNUM -l $PNUM "$SRC" $PAGE
pdflatex -output-directory $TMPDIR $TEX
pdflatex -output-directory $TMPDIR $TEX
rm -f $DST

LASTPAGE=$(pdfinfo "$SRC" | grep -Po '^Pages:\s+\K\d+')
POST=
PRE=

if [ $PNUM -ne 1 ]; then
  PRE="$SRC 1-$((PNUM-1))"
fi

if [ $PNUM -ne $LASTPAGE ]; then
  POST="$SRC $((PNUM+1))-"
fi

pdfjoin -o "$DST" $PRE $SPAGE 1 $POST
rm -rf $TMPDIR
