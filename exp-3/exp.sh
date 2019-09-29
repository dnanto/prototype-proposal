#!/usr/bin/env bash

blastdbcmd -db ../data/db -entry FJ643676.1 -range 30775-31752 > qry.fna

blastn -task megablast -query qry.fna -db ../data/db -outfmt "6 saccver" | \
	blastdbcmd -db ../data/db -entry_batch - > lib.fna

glsearch36 -m 8C -T 8 qry.fna lib.fna > hits.tsv

awk '{ OFS = "\t" } /^[^#]/ && $3 >= 90 { print $2, $9, $10 }' hits.tsv | \
	sort -b | \
	join -t $'\t' - ../data/date.tsv | \
	sort -k 4 | \
	tee def.tsv | \
	awk '$4 != "NA" { printf "s/%s:%d-%d/%s:%d-%d_%s/\n", $1, $2, $3, $1, $2, $3, $4 ; }' > def.sed

awk '{ printf "%s %d-%d\n", $1, $2, $3 }' def.tsv | \
	blastdbcmd -db ../data/db -entry_batch - | \
	sed -f def.sed | \
	mafft --auto --adjustdirection --thread -1 - > msa-1.fna 2> msa-1.log

awk '$4 != "NA" { printf "%s %d-%d\n", $1, $2, $3 }' def.tsv | \
	blastdbcmd -db ../data/db -entry_batch - | \
	sed -f def.sed | \
	mafft --auto --adjustdirection --thread -1 - > msa-2.fna 2> msa-2.log

rm -rf phy-1.* && iqtree -s msa-1.fna -pre phy-1 -alrt 1000 -bb 1000 -bnni -nt AUTO
rm -rf phy-2.* && iqtree -s msa-2.fna -pre phy-2 -alrt 1000 -bb 1000 -bnni -nt AUTO
