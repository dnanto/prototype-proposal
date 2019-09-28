#!/usr/bin/env bash

blastdbcmd -db ../data/db -entry FJ643676.1 -range 30775-31752 > qry.fna

blastn -task megablast -query qry.fna -db ../data/db -outfmt "6 saccver" | \
	blastdbcmd -db ../data/db -entry_batch - > lib.fna

glsearch36 -m 8C -T 8 qry.fna lib.fna > hits.tsv

awk '{ OFS = "\t" } /^[^#]/ { print $2, $9, $10 }' hits.tsv | \
	sort -b | \
	join -1 1 -t $'\t' - ../data/date.tsv | \
	awk '$4 != "NA"' | 
	sort -k 4 | \
	tee def.tsv | \
	awk '{ printf "s/%s:%d-%d/%s:%d-%d_%s/\n", $1, $2, $3, $1, $2, $3, $4 ; }' > def.sed

awk '{ printf "%s %d-%d\n", $1, $2, $3 }' def.tsv | \
	blastdbcmd -db ../data/db -entry_batch - | \
	sed -f def.sed | \
	mafft --auto --adjustdirection --thread -1 - > msa.fna

iqtree -s msa.fna -pre phy -alrt 1000 -bb 1000 -bnni -nt AUTO
