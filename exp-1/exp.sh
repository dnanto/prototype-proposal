#!/usr/bin/env bash

# full genome analysis

blastdbcmd -db ../data/db -entry all -outfmt "%a %l" | \
	awk '$2 > 34000 { print $1; }' | \
	sort -b | \
	join -t $'\t' - ../data/date.tsv | \
	sort -k 2 | \
	tee def.tsv | \
	awk '{ printf "s/^>%s/>%s_%s/\n", $1, $1, $2; }' > def.sed

awk '$2 != "NA" { print $1; }' def.tsv | \
	blastdbcmd -db ../data/db -entry_batch - | \
	sed -f def.sed | \
	mafft --auto --adjustdirection --thread -1 - > msa.fna

iqtree -s msa.fna -pre phy -alrt 1000 -bb 1000 -bnni -nt AUTO
